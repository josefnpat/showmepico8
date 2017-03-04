require './ruby/TUtilities/watcher'
require './ruby/process'
require 'pry-byebug'

SECONDS_BETWEEN_REQUESTS = 25

watcher = ::TUtilities::TMentionWatcher.new

loop do
	puts "Making request @ #{Time.now}"
	target_time = Time.now + SECONDS_BETWEEN_REQUESTS

	watcher.look do |mention, client|
		handle_one_tweet(mention, client)
	end

	sleep(target_time - Time.now) if target_time > Time.now
end

# client = Twitter::REST::Client.new do |c|
# 	c.consumer_key        = profile_data['consumer_key']
# 	c.consumer_secret     = profile_data['consumer_secret']
# 	c.access_token        = profile_data['token']
# 	c.access_token_secret = profile_data['secret']
# end
#
# tweet_id = ARGV[0]
# result = nil # initialize
#
# # puts "Original #{tweet_id}"
#
# begin
# 	tweet = client.status(tweet_id)
# 	result = tweet # default to the original tweet
# 	parent_id = tweet.in_reply_to_status_id
# 	parent_tweet = client.status(parent_id)
#
# 	# replace if it has a parent
# 	result = parent_tweet unless parent_id.is_a? Twitter::NullObject
# rescue # rubocop:disable HandleExceptions
# end
#
# resulthtml = HTMLEntities.new.decode(result.text)
#
# puts "#{result.id}\n#{resulthtml}"
