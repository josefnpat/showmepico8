require 't'
require 'yaml'
require 'htmlentities'

# Provides a connection to Twitter
module TUtilities
	class TYamlConnection
		# Opens a new connection using the info from ~/.trc
		# Use `t authorize` to set up
		def new()
			begin
				t_conf_location = ENV['HOME'] + '/.trc'
				t_conf = YAML.load_file(t_conf_location)
				profile_name = t_conf['configuration']['default_profile'][0]
				profile_id = t_conf['configuration']['default_profile'][1]
				profile_data = t_conf['profiles'][profile_name][profile_id]
			rescue
				puts $ERROR_INFO, $ERROR_POSITION
				raise 'Probalby run `t authorize`'
			end
		end # connect
	end
end # TConnection
