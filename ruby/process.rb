# This file handles ruby-side processing of a single mention
# Ideally it is the only file that will need to be modified
# @param mention: The Twitter::Tweet that is mentioning you. http://www.rubydoc.info/gems/twitter/Twitter/Tweet
# @param watcher: The Watcher that called you.
# watcher.username is the user.screen_name equivalent
# watcher.client is http://www.rubydoc.info/gems/twitter/Twitter/REST/Client
def handle_one_tweet(mention, watcher)
	target_tweet = discern_target_tweet(mention, watcher)
	lua = tweet_to_lua(target_tweet, watcher)
	gif = lua_to_gif_io(lua)
	reply_with_gif_or_sadness(mention, watcher, gif)
end

# Constructs the tagging string with all relevant usernames
# If this is not done, it will be posted as a non-reply status.
def build_tagging_text(mention, watcher)
	mentioned_users = mention.user_mentions.map(&:screen_name)
	mentioned_users.push mention.user.screen_name
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
		watcher.client.update_with_media(status, media_stream, in_reply_to_status: mention)
	else
		status = "#{tagging_text} :( it went boom"
		watcher.client.update(status, in_reply_to_status: mention)
	end

	puts status
end

# Attempts to discern the target tweet from a given mention.
def discern_target_tweet(mention, watcher)
	parent_id = mention.in_reply_to_status_id

	# The current tweet is the target if there is no parent.
	return mention if parent_id.is_a? Twitter::NullObject

	parent = watcher.client.status(parent_id)

	# The current tweet is the target if the parent is us.
	return mention if parent.user.screen_name.casecmp(watcher.username)

	parent
end

# Gets lua from the tweet.
def tweet_to_lua(target_tweet, watcher)
	target_tweet.text
end

# Turns lua into a streamable file handle
def lua_to_gif_io(lua)
	nil # binding.pry
end
