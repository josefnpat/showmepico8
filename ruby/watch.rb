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
