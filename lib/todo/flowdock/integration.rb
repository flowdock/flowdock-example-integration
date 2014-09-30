require 'sinatra/base'

module Todo
  module Flowdock
    module SinatraIntegration
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
        app.helpers SinatraIntegration::Helpers

        app.get '/auth/flowdock/callback' do
          auth = request.env['omniauth.auth']
          omniauth_params = request.env['omniauth.params']
          session[:flowdock_token] = auth[:credentials][:token]
          redirect to("/flowdock/setup?flow=#{omniauth_params['flow']}")
        end

        app.get '/flowdock/setup' do
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
            name: "Example application"
          })
          session[:integration_token] = integration.body["flow_token"]
          @flow_name = params[:flow_name]
          slim :"flowdock/success"
        end
      end
    end
  end
end
