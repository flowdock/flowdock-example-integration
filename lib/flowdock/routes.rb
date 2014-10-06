require 'sinatra/base'
require_relative 'integration'

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
        @flow = oauth_connection.get("/flows/find?id=#{omniauth_params['flow']}").body
        slim :"flowdock/connect"
      end

      app.get '/flowdock/setup' do
        #See base.rb for the magical Omniauth url
        redirect to("/auth/flowdock?flow=#{params[:flow]}")
      end

      app.get '/auth/failure' do
        "Oauthentication with Flowdock failed"
      end

      app.post '/flowdock/integrate' do
        path = URI.parse(params[:flow_url]).path
        integration = oauth_connection.post("#{path}/integrations", {
          name: "Public"
        })
        FlowdockIntegration.create!(token: integration.body["flow_token"])
        @flow_name = params[:flow_name]
        session.delete(:flowdock_token)
        slim :"flowdock/success"
      end
    end
  end
end
