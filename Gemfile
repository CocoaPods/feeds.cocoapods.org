source 'https://rubygems.org'
ruby '2.1.3'

# App
group :app do
  gem 'sinatra', :require => 'sinatra/base'
  gem 'sinatra-partial'
  gem 'sinatra-support'
  gem 'sinatra-contrib'
  gem 'activesupport'
  gem 'dotenv'
  gem 'i18n'

  gem 'cocoapods-core'
  gem 'colored'
  gem 'exceptio-ruby'
  gem 'faraday-http-cache'
  gem 'json'
  gem 'mime-types'
  gem 'octokit'
  gem 'pygments.rb'
  gem 'redcarpet'
  gem 'sinatra-cache'
  gem 'twitter'
  gem 'nap'
  gem 'pg'
  
  gem 'dm-core', require: true
  gem 'dm-do-adapter', require: true
  gem 'dm-postgres-adapter', require: true
  
end

group :heroku_plugins do
  gem "bugsnag"
  gem 'newrelic_rpm'
end

group :assets do
  gem 'haml'
  gem 'sass'
  gem 'slim'
  gem 'sinatra-asset-pipeline'
end

group :database do
  gem 'sequel'
end

group :mail do
  # gem 'mail'
  # gem 'gibbon'
  gem 'pony'
end

group :server do
  gem 'foreman'
  gem 'thin'
end

group :development do
  gem 'rake'
  gem 'heroku'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'kicker'
  gem 'terminal-table'
  gem 'rubocop'
end

group :test do
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'prettybacon'
  # gem 'nokogiri'
  gem 'rack-test'
  gem 'coveralls', :require => false
end

