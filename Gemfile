source 'https://rubygems.org'
ruby '2.1.2'

gem 'foreman'
gem 'dotenv'
gem 'sinatra', '~> 1.4'
gem 'slim', '~> 2.0'
gem 'puma', '~> 2.8.2'
gem 'activerecord', '~> 4.1.14.1'
gem 'rack_csrf', '~> 2.5.0'

# Authentication
gem 'omniauth', '~> 1.3.2'
gem 'omniauth-flowdock'

# API
gem 'faraday', '~> 0.9'
gem 'faraday_middleware'

# Assets
gem 'sinatra-asset-pipeline'
gem 'sprockets', '~> 2.12.5'
gem 'compass', '~> 1.0.0.alpha.21'
gem 'nokogiri', '~> 1.8.1'
gem 'bootstrap-sass', '~> 3.2.0.2'

group :development do
  gem 'sqlite3', '~> 1.3.9'
  gem 'rerun', require: false
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'rake'
  gem 'pry-byebug', '~> 1.3'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

group :production do
  gem 'pg'
end
