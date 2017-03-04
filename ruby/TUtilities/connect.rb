require 't'
require 'yaml'

# Provides a connection to Twitter
module TUtilities
	# Utilities for connecting with t
	module Connect
		# Creates a connection using the profile data found in ~/.trc
		def self.connect_with_t
			connect_with t_profile_data
		end

		# Connects using t with the given profile data.
		# Must contain consumer_key, consumer_secret, token, secret
		def self.connect_with(profile_data)
			client = Twitter::REST::Client.new do |c|
				c.consumer_key        = profile_data['consumer_key']
				c.consumer_secret     = profile_data['consumer_secret']
				c.access_token        = profile_data['token']
				c.access_token_secret = profile_data['secret']
			end

			client
		end

		# Gets the profile info from ~/.trc
		# Use `t authorize` to set up
		def self.t_profile_data
			t_conf_location = ENV['HOME'] + '/.trc'
			t_conf = YAML.load_file(t_conf_location)
			profile_name = t_conf['configuration']['default_profile'][0]
			profile_id = t_conf['configuration']['default_profile'][1]
			profile_data = t_conf['profiles'][profile_name][profile_id]
			return profile_data
		rescue
			puts $ERROR_INFO, $ERROR_POSITION
			raise 'Probalby run `t authorize`'
		end
	end
end
