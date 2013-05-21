require 'twitter'
require 'google_plus'
require 'googl'
require 'yaml'

def load_env_properties()
	properties = YAML.load_file('gplus_twitter_config.yml')

	@twitter_consumer_key = properties['twitter_consumer_key']
	@twitter_consumer_secret = properties['twitter_consumer_secret']
	@twitter_oauth_token = properties['twitter_oauth_token']
	@twitter_oauth_token_secret = properties['twitter_oauth_token_secret']

	@google_plus_api_key = properties['google_plus_api_key']
	@google_plus_user_id = properties['google_plus_user_id']

	puts properties
end

def update_last_posted_id(etag)
	@last_posted_etag = etag
	File.open(LAST_ETAG_FILE_NAME, 'w') {|f| f.write(etag)}
end

def build_post(post, url_string)
	post + " " + url_string
end

def post_tweet(data)
	Twitter.configure do |config|
		config.consumer_key = @twitter_consumer_key
		config.consumer_secret = @twitter_consumer_secret
		config.oauth_token = @twitter_oauth_token
		config.oauth_token_secret = @twitter_oauth_token_secret
	end

	puts "posting tweet #{data[:tweet_string]}"

	begin
		Twitter.update(data[:tweet_string], {:lat => data[:tweet_lat], :long => data[:tweet_long]})
	rescue Twitter::Error::Forbidden => e
		puts "\n============================\n"		
		puts "error posting to twitter!!!"
		puts e.message
		puts e.backtrace.inspect
		puts "\n============================\n"
	end
end

def build_tweet_data(item)
	tweet_data = {}

	#get shortened url object
	url = Googl.shorten(item.url)

	#check if post to G+ or a repost
	if item.provider.attributes['title'] == 'Google+'
		tweet_data[:tweet_string] = build_post(item.title, url.short_url)
	else 
		tweet_data[:tweet_string] = build_post(item.annotation, url.short_url)	
	end

	#check if post has location attached to it
	if item.attributes['location']
		tweet_data[:tweet_lat] = item.location.position.latitude
	 	tweet_data[:tweet_long] = item.location.position.longitude
	end

	tweet_data
end

def post_new_activities(items)
	new_items = false

	if @last_posted_etag == nil
		new_items = true
	end

	items.each do |item|
		if !new_items 
			if item.etag.gsub(/"|\\/, "") == @last_posted_etag
				new_items = true
			end
		else
			if new_items and item.access.kind == 'plus#acl' 
				tweet_data = build_tweet_data(item)
				post_tweet(tweet_data)
				update_last_posted_id(item.etag.gsub(/"|\\/, ""))
			end
		end
	end
end

##### BEGIN APP LOGIC #########
LAST_ETAG_FILE_NAME = 'lastetag.txt'
@last_posted_etag = nil

load_env_properties

if File.exist? LAST_ETAG_FILE_NAME
	@last_posted_etag = File.open(LAST_ETAG_FILE_NAME).read.strip
	puts "found last id #{@last_posted_etag}"
end

while true do 
	GooglePlus.api_key = @google_plus_api_key
	gplus_me = GooglePlus::Person.get(@google_plus_user_id)
	items = gplus_me.list_activities.items
	items = items.reverse

	post_new_activities(items)

	puts "Sleeping for 60 seconds"
	sleep 60
end

