require 'rubygems'
require 'bundler/setup'
require 'json'
Bundler.require :default
require 'sinatra/asset_pipeline'
require_relative 'config/base'
require_relative "view_helper"

$stdout.sync = true

require 'active_record'

require_relative 'lib/flowdock/create_poll'
require_relative 'lib/flowdock/close_poll'
require_relative 'lib/flowdock/vote'
require_relative 'lib/flowdock/routes'

require_relative 'models/poll'
require_relative 'models/option'
require_relative 'models/vote'

require 'securerandom'

register Flowdock::Routes
use ActiveRecord::ConnectionAdapters::ConnectionManagement

@environment = ENV['RACK_ENV']
@dbconfig = YAML.load(ERB.new(File.read(File.join("config","database.yml"))).result)
ActiveRecord::Base.establish_connection @dbconfig[@environment]

require_relative 'schema'

use Rack::Static, :urls => ['/assets'], :root => 'assets'

get '/' do
  if !session.has_key?(:user)
    session[:user] = {
      id: SecureRandom.hex
    }
  end
  @integration_set = session.has_key?(:integration_token)
  @open_polls = Poll.where(status: "open")
  @closed_polls = Poll.where(status: "closed")
  slim :index
end

get '/create' do
  slim :create
end

post '/create' do
  poll = Poll.create!(
    title: Rack::Utils.escape_html(params[:title]),
    status: "open"
  )

  options = params[:options].split(",")
  for option in options
    poll.options.push Option.create!(poll: poll, title: Rack::Utils.escape_html(option).strip())
  end

  Flowdock::CreatePoll.new(poll, session[:user]).save()
  redirect to("/")
end

post '/vote/:poll_id' do
  poll = Poll.find(params[:poll_id])
  option = poll.options.find(params[:option])
  vote = option.votes.create!(user_id: session[:user][:id])
  Flowdock::Vote.new(vote, session[:user]).save()
  redirect to("/")
end

post '/close/:poll_id' do
  poll = Poll.find(params[:poll_id])
  poll.update!(status: "closed")
  Flowdock::ClosePoll.new(poll, session[:user]).save()
  redirect to("/")
end