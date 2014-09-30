require 'rubygems'
require 'bundler/setup'
require 'json'
Bundler.require :default
require 'sinatra/asset_pipeline'
require_relative 'config/base'
require_relative "view_helper"

$stdout.sync = true

require_relative 'lib/todo/flowdock/activity'
require_relative 'lib/todo/flowdock/integration'

register Todo::Flowdock::SinatraIntegration

get '/' do
  @integration_set = session.has_key?(:integration_token)
  slim :index
end

post '/activity' do
  Todo::Flowdock::Activity.new(params).save(session[:integration_token])
  redirect to("/")
end
