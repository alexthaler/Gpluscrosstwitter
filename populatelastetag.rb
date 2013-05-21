require 'yaml'
require 'google_plus'

props = YAML.load_file('gplus_twitter_config.yml')

@google_plus_api_key = props['google_plus_api_key']
@google_plus_user_id = props['google_plus_user_id']

GooglePlus.api_key = @google_plus_api_key
gplus_me = GooglePlus::Person.get(@google_plus_user_id)
items = gplus_me.list_activities.items

File.open('lastetag.txt', 'w') {|f| f.write(items.first.etag.gsub(/"|\\/, ""))}