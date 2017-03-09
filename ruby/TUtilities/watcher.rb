require './ruby/TUtilities/connect'
require 'yaml/store'

# Utilities that work with `t`
module TUtilities
	# Watches Mentions
	# Stores latest seen in TMentionWatcher.store.yaml
	class TMentionWatcher
		attr_reader :username, :client

		def initialize
			@store = YAML::Store.new 'TMentionWatcher.store.yaml'
			@username = ::TUtilities::Connect.t_username
			@client = ::TUtilities::Connect.connect_with_t

			# ensure we don't go rogue
			self.stored_since_id = my_last_tweet.id
		end

		def stored_since_id=(val)
			@store.transaction do
				@store['since_id'] = val
			end
		end

		def stored_since_id
			@store.transaction do
				return @store['since_id']
			end
		end

		def my_last_tweet
			res = client.user_timeline @username
			res.first
		end

		# Gets the latest mentions and passes them to a block. |mention, self|
		# Updates the since_id
		def look
			raise 'block required' unless block_given?
			mentions = latest_mentions(stored_since_id)
			mentions.each do |mention|
				yield(mention, self)
			end
			self.stored_since_id = mentions.first.id if mentions.any?
		end

		private

		# Gets mentions since the latest since_id
		def latest_mentions(since_id)
			if since_id
				client.mentions_timeline since_id: since_id
			else
				client.mentions_timeline
			end
		end
	end
end
