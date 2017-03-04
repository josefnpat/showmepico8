require 't'
require 'yaml'
require 'htmlentities'

begin
    t_conf = YAML.load_file(ENV['HOME']+'/.trc')
    profile_name = t_conf['configuration']['default_profile'][0]
    profile_id = t_conf['configuration']['default_profile'][1]
    profile_data = t_conf['profiles'][profile_name][profile_id]
rescue
    puts $!, $@
    fail "Probalby run `t authorize`"
end

client = Twitter::REST::Client.new do |c|
    c.consumer_key        = profile_data['consumer_key']
    c.consumer_secret     = profile_data['consumer_secret']
    c.access_token        = profile_data['token']
    c.access_token_secret = profile_data['secret']
end

tweet_id = ARGV[0]
result = nil # initialize

# puts "Original #{tweet_id}"

begin
    tweet = client.status(tweet_id)
    result = tweet # default to the original tweet
    parent_id = tweet.in_reply_to_status_id
    parent_tweet = client.status(parent_id)

    # replace if it has a parent
    result = parent_tweet unless parent_id.is_a? Twitter::NullObject
rescue
    # fuck exceptions
end

resulthtml = HTMLEntities.new.decode(result.text)

puts "#{result.id}\n#{resulthtml}"
