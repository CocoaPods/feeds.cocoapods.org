$LOAD_PATH << File.expand_path('../', __FILE__)
$LOAD_PATH << File.expand_path('../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'
require 'config/init'
require 'rack'
require 'app/controllers'

module FeedsApp
  App = Rack::URLMap.new(
    '/'       => Controllers::WebController,
    '/hooks'  => Controllers::HooksController,
  )
end

