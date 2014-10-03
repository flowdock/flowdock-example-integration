require 'sinatra/base'
require_relative 'integration'
require_relative '../../models/user'

module Flowdock
  module Routes
    module Helpers
      def oauth_connection
        Faraday.new FLOWDOCK_URL do |connection|
          connection.request :oauth2, session[:flowdock_token]
          connection.request :json
          connection.response :json, content_type: /\bjson$/
          connection.response :logger if logger.debug?
          connection.use Faraday::Response::RaiseError
          connection.adapter Faraday.default_adapter
        end
      end
    end

    def self.registered(app)
      app.helpers Routes::Helpers

      app.get '/auth/flowdock/callback' do
        auth = request.env['omniauth.auth']
        omniauth_params = request.env['omniauth.params']
        session[:flowdock_token] = auth[:credentials][:token]
        if omniauth_params['flow']
          redirect to("/flowdock/setup?flow=#{omniauth_params['flow']}")
        else
          user = User.find_by(email: auth[:info][:email])
          if user
            user.update!(session_token: SecureRandom.hex)
          else
            user = User.create!(
              session_token: SecureRandom.hex,
              name: auth[:info][:name],
              email: auth[:info][:email],
              nick: auth[:info][:nickname]
            )
          end
          session[:token] = user.session_token
          redirect to("/")
        end
      end

      app.get '/flowdock/setup' do
        #store flow_id to session
        #solve redirect loop, although the flows - view would solve this I guess
        if session.has_key?(:flowdock_token)
          begin
            @flow = oauth_connection.get("/flows/find?id=#{params[:flow]}").body
          rescue Faraday::Error::ClientError => e
            if defined? e.response && e.response[:status] == 401
              redirect to("/auth/flowdock?flow=#{params[:flow]}")
            else
              raise e
            end
          end
          slim :"flowdock/connect"
        else
          redirect to("/auth/flowdock?flow=#{params[:flow]}")
        end
      end

      app.post '/flowdock/integrate' do
        path = URI.parse(params[:flow_url]).path
        integration = oauth_connection.post("#{path}/integrations", {
          name: "Public"
        })
        #integration id, flow name, flow db_id
        FlowdockIntegration.create!(token: integration.body["flow_token"])
        @flow_name = params[:flow_name]
        slim :"flowdock/success"
      end
    end

    # app.get 'flowdock/configure/' do
    #   #params[:flow]
    #   #params[:integration_id]
    # end
  end
end
