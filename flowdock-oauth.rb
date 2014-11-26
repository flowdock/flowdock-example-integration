#!/usr/bin/env ruby
# This example is a standalone command line script, which authenticates with 
# Flowdock and sets up everything that's required to test out the API
begin
  require 'oauth2'
rescue LoadError
  puts "You need to install oauth2 gem, run `gem install oauth2`"
  exit 1
end
 
require 'uri'
require 'net/http'
 
redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
$site = ENV['FLOWDOCK_API_URL'] || "https://api.flowdock.com"
$email = nil
$password = nil
 
def ask_credentials
  return if $email
  puts "\nPlease input your login email address\n"
  $email = gets.chomp
  puts "Please input your password\n"
  $password = gets.chomp
end
 
if ENV['FLOWDOCK_OAUTH_APP_ID'] && ENV['FLOWDOCK_OAUTH_APP_SECRET']
  client_id = ENV['FLOWDOCK_OAUTH_APP_ID']
  client_secret = ENV['FLOWDOCK_OAUTH_APP_SECRET']
  puts "Using preconfigured OAuth app #{client_id}."
else
  puts "First, let's setup an OAuth app."
  puts "\nYou can skip this by adding\n  FLOWDOCK_OAUTH_APP_ID\n  FLOWDOCK_OAUTH_APP_SECRET\nto your environment variables."
 
  ask_credentials
 
  puts "\nPlease input a name for your app, eg. the name of the service you're integrating.\n"
  app_name = gets.chomp
 
  url = URI("#{$site}/oauth/applications")
 
  response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
    req = Net::HTTP::Post.new(url.path)
    req.body = JSON.dump(application: {name: app_name, redirect_uri: redirect_uri})
    req.basic_auth $email, $password
    req['Accept'] = 'application/json'
    req['Content-Type'] = 'application/json'
    http.request(req)
  end
  if response.code.to_i < 400
    app_data = JSON.parse(response.body)
  else
    puts "Failed creating app with code #{response.code}:"
    puts response.body.inspect
    exit 1
  end
 
  puts "\nCreated OAuth app:"
  puts "Application id: #{app_data['client_id']}"
  puts "Application secret: #{app_data['client_secret']}"
 
  client_id = app_data['client_id']
  client_secret = app_data['client_secret']
end
 
ask_credentials
 
puts "\nCreating an access token. Continue?\n"
gets
 
client = OAuth2::Client.new(client_id, client_secret, :site => $site)
token = client.password.get_token($email, $password, redirect_uri: redirect_uri, scope: 'flow integration')
puts "\nYour OAuth token is:\n====================\n#{token.token}\n===================="
 
puts "\n\nNow fetching your flows"
response = token.get('/flows.json')
flows = JSON.parse(response.body).select { |flow| flow['open'] }
 
puts 'Flows you have open: '
flows.each_with_index do |flow, index|
  puts "#{index + 1}. #{flow['name']} (#{flow['organization']['name']})"
end
 
puts "\nNext we'll create a source in each flow."
puts "Please input a comma separated list of flows you want to add (1,3,5) or hit enter to create a source in every flow.\n"
input = gets.chomp
flows_to_add = if input == ''
   flows
else
  input.split(',').map(&:chomp).map(&:to_i).map { |i| flows[i-1] }
end
puts "Selected #{flows_to_add.size} flows."
 
puts "Name for the source (Example: When integrating a project management tool, a source would represent a project.):\n"
source_name = gets.chomp
puts "\nCreating sources:"
 
data = nil
flows_to_add.each do |flow|
  response = token.post("#{flow["url"]}/sources", body: {name: source_name})
  data = JSON.parse(response.body)
  puts "Flow #{flow['name']} (#{flow['organization']['name']}) with id #{flow['id']}:"
  puts "Source { id: #{data['id']}, name: '#{data['name']}', flow_token: '#{data['flow_token']}' }"
end
 
f = flows_to_add.last
 
puts "\nFinally, here's an example curl command for posting a message to a thread in the #{f['name']} flow:"
puts %Q(\ncurl -i -X POST -H "Content-Type: application/json" -d '{
"flow_token": "#{data['flow_token']}",
  "event": "activity",
  "author": {
    "name": "Tom",
    "avatar": "https://avatars.githubusercontent.com/u/3017123?v=3"
  },
  "title": "updated ticket",
  "external_thread_id": "1234567",
  "thread": {
    "title": "Polish the flux capacitor",
    "fields": [{ "label": "Dustiness", "value": "5 - severe" }],
    "body": "The flux capacitor has been in storage for more than 30 years and it needs to be spick and span for the re-launch.",
    "external_url": "https://example.com/projects/bttf/tickets/1234567",
    "status": {
      "color": "green",
      "value": "open"
    }
  }
}' #{$site}/messages\n)