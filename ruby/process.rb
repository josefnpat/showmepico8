require 'htmlentities'
require 'yaml'

# Raise when the tweet should not be sent.
class CancelTweetException < StandardError
end

# This file handles ruby-side processing of a single mention
# Ideally it is the only file that will need to be modified
# @param mention: The Twitter::Tweet that is mentioning you. http://www.rubydoc.info/gems/twitter/Twitter/Tweet
# @param watcher: The Watcher that called you.
# watcher.username is the user.screen_name equivalent
# watcher.client is http://www.rubydoc.info/gems/twitter/Twitter/REST/Client
# see `test_lua_to_temp_gif` for lua rendering test information
def handle_one_tweet(mention, watcher)
	target_tweet = discern_target_tweet(mention, watcher)
	lua = tweet_to_lua(target_tweet, watcher)
	lua_to_temp_gif(lua) do |gif|
		reply_with_gif_or_sadness(mention, watcher, gif)
	end
rescue CancelTweetException => e
	tagging_text = build_tagging_text(mention, watcher)
	puts "canceled - #{tagging_text} - #{e.message}"
end

# Constructs the tagging string with all relevant usernames
# If this is not done, it will be posted as a non-reply status.
def build_tagging_text(mention, watcher)
	mentioned_users = mention.user_mentions.map(&:screen_name)
	mentioned_users.push(mention.user.screen_name)
	mentioned_users.delete(watcher.username)
	mentioned_users.map! { |screen_name| '@' + screen_name }
	mentioned_users.join(' ')
end

# Replies to the user.
# If there is a gif, :sign_of_the_horns: + gif
# If there isn't a gif, sadness
def reply_with_gif_or_sadness(mention, watcher, gif)
	tagging_text = build_tagging_text(mention, watcher)

	if gif
		status = "🤘 #{tagging_text}"
		watcher.client.update_with_media(status, gif, in_reply_to_status: mention)
		puts "!!gif!! - #{tagging_text}"
	else
		status = "#{tagging_text} :( it went boom"
		watcher.client.update(status, in_reply_to_status: mention)
		puts "no gif - #{tagging_text}"
	end

	puts status
rescue => e
	status = "#{tagging_text} :( it went boom\n#{e.message}"
	watcher.client.update(status, in_reply_to_status: mention)
	puts "reply broke - #{tagging_text}"
end

# Attempts to discern the target tweet from a given mention.
def discern_target_tweet(mention, watcher)
	parent_id = mention.in_reply_to_status_id

	# The current tweet is the target if there is no parent.
	if parent_id.is_a? Twitter::NullObject
		throw_if_obviously_bad(mention, 'original', 'parent is null')
		return mention
	end

	parent = watcher.client.status(parent_id)

	# The current tweet is the target if the parent is us.
	if parent.user.screen_name.downcase == watcher.username.downcase
		throw_if_obviously_bad(mention, 'original', 'parent is us')
		return mention
	end

	throw_if_obviously_bad(parent, 'parent')
	parent
end

def throw_if_obviously_bad(tweet, friendly_name, why = nil)
	context = "#{friendly_name} text started with @ (#{why})"
	raise CancelTweetException, context if tweet.text.start_with? '@'
	tweet
end

# Gets lua from the tweet.
def tweet_to_lua(target_tweet, _watcher)
	target_tweet.text
end

# Turns lua into a streamable file handle
def lua_to_temp_gif(lua)
	raise 'block required' unless block_given?

	# TODO: Parameterize?
	shared_config = YAML.load_file('./config.yml')
	lua_location = shared_config['record_input']
	gif_location = shared_config['record_output']
	# Dump the cart to `tweetcart.raw.lua`
	File.open(lua_location, 'w') { |f| f.write(lua) }

	# Await the saving grace of the magic
	output = `script -q -f -c "./recordpico8.bash"`

	# Cancel if there was a syntax error
	raise TweetCanceled, 'syntax error' if output.include?('syntax error')

	# Read the file and hopefully tweet it.
	File.open(gif_location, 'r') { |gif| yield(gif) }

	# PURGE
	File.delete(gif_location)
	File.delete(lua_location)
rescue TweetCanceled
	# PURGE
	File.delete(gif_location)
	File.delete(lua_location)
	raise
end

# Extracts a syntax error message from script output
def script_output_to_syntax_error(output)
	syntax_error = /syntax error line.*\r\n(.*)\r\nConverting/m.match(output)

	return syntax_error[1] if syntax_error

	return 'unidentified syntax error'
rescue
	return 'unidentified syntax error'
end

# This will test just the giffing
# run `gem install bundler`
# run `bundle install`
# run `bundle exec ruby ruby/process.rb`
def test_lua_to_temp_gif
	require 't'

	lua = <<-LUA_CODE
print("hello world")
LUA_CODE

	lua_to_temp_gif(lua) do |gif|
		raise(Twitter::Error::UnacceptableIO.new) unless gif.respond_to?(:to_io)
	end
end

# Run the test script if executing this file directly
test_lua_to_temp_gif if __FILE__ == $PROGRAM_NAME
