Dotenv.load

configure :development do
  require 'better_errors'
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

configure :production do
  enable :raise_errors
end

set :assets_precompile, %w(*.png *.jpg *.svg *.eot *.ttf *.woff *.css)
set :assets_css_compressor, :sass

use Rack::Session::Cookie, secret: ENV['COOKIE_SECRET']
set :public_folder, File.dirname(__FILE__) + "/../static"
set :views, File.dirname(__FILE__) + "/../views"

FLOWDOCK_URL = ENV['FLOWDOCK_URL'] || 'https://api.flowdock.com'

use OmniAuth::Builder do
  provider :flowdock, ENV['FLOWDOCK_CLIENT_ID'], ENV['FLOWDOCK_CLIENT_SECRET'],
    scope: 'profile integration',
    client_options: {
      site: FLOWDOCK_URL,
      authorize_url: "/oauth/authorize"
    }
end

OmniAuth.config.failure_raise_out_environments = []

register Sinatra::AssetPipeline
