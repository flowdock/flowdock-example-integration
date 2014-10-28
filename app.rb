require 'rubygems'
require 'bundler/setup'
require 'json'
Bundler.require :default
require 'sinatra/asset_pipeline'
require_relative 'config/base'

$stdout.sync = true

require 'active_record'

require_relative 'lib/flowdock/create_poll'
require_relative 'lib/flowdock/close_poll'
require_relative 'lib/flowdock/comment_poll'
require_relative 'lib/flowdock/vote'
require_relative 'lib/flowdock/routes'
require_relative 'lib/flowdock/new_option'
require_relative 'lib/flowdock/unvote'

require_relative 'models/poll'
require_relative 'models/option'
require_relative 'models/vote'
require_relative 'models/comment'
require_relative 'models/user'

require 'securerandom'
require 'rack/csrf'

register Flowdock::Routes
use ActiveRecord::ConnectionAdapters::ConnectionManagement
use Rack::Csrf

@environment = ENV['RACK_ENV'] || "development"
@dbconfig = YAML.load(ERB.new(File.read(File.join("config","database.yml"))).result)
ActiveRecord::Base.establish_connection @dbconfig[@environment]

require_relative 'schema'

def current_user
  user = User.find_by(session_token: session[:token])
  if !user
    redirect to("/authentication_required")
  else
    user
  end
end

get '/authentication_required' do
  slim :authentication_required
end

get '/' do
  current_user
  @integration_set = session.has_key?(:integration_token)
  @open_polls = Poll.where(status: "open")
  @closed_polls = Poll.where(status: "closed")
  slim :index
end

get '/create' do
  current_user
  slim :create
end

post '/create' do
  current_user
  poll = Poll.create!(
    title: params[:title].strip(),
    status: "open"
  )

  options = params[:options].split(",")
  for option in options
    poll.options.push Option.create!(poll: poll, title: option.strip())
  end

  Flowdock::CreatePoll.new(poll, current_user).save()
  redirect to("/")
end

post '/:poll_id/vote' do
  current_user
  poll = Poll.find(params[:poll_id])
  option = poll.options.find(params[:option])
  vote = Vote.create!(option: option, user: current_user)
  Flowdock::Vote.new(vote, current_user).save()
  if params[:redirect]
    redirect to("/")
  else
    redirect to("/" + params[:poll_id])
  end
end

delete '/:poll_id/unvote' do
  current_user
  poll = Poll.find(params[:poll_id])
  option = poll.options.find(params[:option])
  vote = Vote.find_by(option: option, user: current_user)
  vote.destroy!
  Flowdock::UnVote.new(vote, current_user).save()
  if params[:redirect]
    redirect to("/")
  else
    redirect to("/" + params[:poll_id])
  end
end

post '/:poll_id/close' do
  current_user
  poll = Poll.find(params[:poll_id])
  poll.update!(status: "closed")
  Flowdock::ClosePoll.new(poll, current_user).save()
  redirect to("/" + params[:poll_id])
end

post '/:poll_id/comment' do
  current_user
  poll = Poll.find(params[:poll_id])
  comment = Comment.create!(poll: poll, comment: params[:comment].strip())
  Flowdock::CommentPoll.new(comment, current_user).save()
  redirect to("/" + params[:poll_id])
end

post '/:poll_id/add_option' do
  current_user
  poll = Poll.find(params[:poll_id])
  option = Option.create!(poll: poll, title: params[:title].strip())
  Flowdock::NewOption.new(option, current_user).save()
  redirect to("/" + params[:poll_id])
end

get '/:poll_id' do
  current_user
  begin
    @poll = Poll.find(params[:poll_id])
  rescue ActiveRecord::RecordNotFound
    halt(404)
  end
  slim :poll
end
