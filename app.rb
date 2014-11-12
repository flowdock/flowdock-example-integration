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
require_relative 'lib/flowdock/vote_change'

require_relative 'models/poll'
require_relative 'models/option'
require_relative 'models/vote'
require_relative 'models/comment'
require_relative 'models/user'

require 'securerandom'
require 'rack/csrf'
require 'openssl'

register Flowdock::Routes
use ActiveRecord::ConnectionAdapters::ConnectionManagement
use Rack::Csrf, :skip_if => lambda { |request|
  request.env.key?('HTTP_FLOWDOCK_TOKEN')
}

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

def api_user
  token, _ = JWT.decode(request.env['HTTP_FLOWDOCK_TOKEN'], ENV['FLOWDOCK_CLIENT_SECRET'])
  request_data = request.body.read
  if !Rack::Utils.secure_compare(token["signature"], Digest::SHA256.hexdigest(request_data))
    halt 403
  else
    # Uncomment next line to test the authentication path in Flowdock
    #halt 401, {"www-authenticate" => "Flowdock-Token url=#{ENV['WEB_URL']}/auth/flowdock"}, "Authentication required"
    flowdock_user_id = token["sub"]
    user = User.find_by(flowdock_user_id: flowdock_user_id)
    if user
      user
    else
      request_user = JSON.parse(request_data)["agent"]
      user = User.create!(
        name: request_user["name"],
        flowdock_user_id: flowdock_user_id,
        image: request_user["image"]
      )
    end
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

get '/polls/create' do
  current_user
  slim :create
end

post '/polls/create' do
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

def vote(poll_id, option_id, user)
  poll = Poll.find(poll_id)
  option = poll.options.find(option_id)
  voted_option = poll.voted_option_for_user(user)
  if voted_option.nil?
    vote = Vote.create!(option: option, user: user)
    Flowdock::Vote.new(vote, user).save()
  elsif option != voted_option
    previous_vote = Vote.find_by(user: user, option: voted_option).destroy!
    vote = Vote.create!(option: option, user: user)
    Flowdock::VoteChange.new(vote, previous_vote, user).save()
  end
end

post '/polls/:poll_id/vote' do
  vote(params[:poll_id], params[:option], current_user)
  if params[:redirect]
    redirect to("/")
  else
    redirect to("/polls/" + params[:poll_id])
  end
end

# Voting from Flowdock thread actions!
post '/api/polls/:poll_id/vote/:option_id' do
  vote(params[:poll_id], params[:option_id], api_user)
  status 200
end

post '/api/polls/:poll_id/close' do
  user = api_user
  poll = Poll.find(params[:poll_id])
  poll.update!(status: "closed")
  Flowdock::ClosePoll.new(poll, user).save()
  status 200
end


delete '/polls/:poll_id/unvote' do
  current_user
  poll = Poll.find(params[:poll_id])
  option = poll.options.find(params[:option])
  vote = Vote.find_by(option: option, user: current_user)
  vote.destroy!
  Flowdock::UnVote.new(vote, current_user).save()
  if params[:redirect]
    redirect to("/")
  else
    redirect to("/polls/" + params[:poll_id])
  end
end

post '/polls/:poll_id/close' do
  current_user
  poll = Poll.find(params[:poll_id])
  poll.update!(status: "closed")
  Flowdock::ClosePoll.new(poll, current_user).save()
  redirect to("/polls/" + params[:poll_id])
end

post '/polls/:poll_id/comment' do
  current_user
  poll = Poll.find(params[:poll_id])
  comment = Comment.create!(poll: poll, comment: params[:comment].strip())
  Flowdock::CommentPoll.new(comment, current_user).save()
  redirect to("/polls/" + params[:poll_id])
end

post '/polls/:poll_id/add_option' do
  current_user
  poll = Poll.find(params[:poll_id])
  option = Option.create!(poll: poll, title: params[:title].strip())
  Flowdock::NewOption.new(option, current_user).save()
  redirect to("/polls/" + params[:poll_id])
end

get '/polls/:poll_id' do
  current_user
  begin
    @poll = Poll.find(params[:poll_id])
  rescue ActiveRecord::RecordNotFound
    halt(404)
  end
  slim :poll
end
