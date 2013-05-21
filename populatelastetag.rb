require 'yaml'
require 'google_plus'

@google_plus_api_key = YAML.load_file('gplus_twitter_config.yml')['google_plus_api_key']

GooglePlus.api_key = @google_plus_api_key
gplus_me = GooglePlus::Person.get(114333671116123568732)
items = gplus_me.list_activities.items

File.open('lastetag.txt', 'w') {|f| f.write(items.first.etag.gsub(/"|\\/, ""))}