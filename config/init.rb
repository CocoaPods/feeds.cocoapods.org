# -- General ------------------------------------------------------------------

ROOT = File.expand_path('../../', __FILE__)
$LOAD_PATH.unshift File.join(ROOT, 'lib')

ENV['RACK_ENV'] ||= 'development'
ENV['DATABASE_URL'] ||= "postgres://localhost/pod_feeds_app_#{ENV['RACK_ENV']}"

# -- Database -----------------------------------------------------------------

require 'sequel'
require 'pg'

db_loggers = []
DB = Sequel.connect(ENV['DATABASE_URL'], loggers: db_loggers)
Sequel.extension :core_extensions, :migration

#-- Octokit ------------------------------------------------------------------#

# TODO move
require 'octokit'
require 'faraday-http-cache'
stack = Faraday::RackBuilder.new do |builder|
  # builder.response :logger # Useful for debug
  builder.use Faraday::HttpCache
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack

OCTOKIT_CLIENT = Octokit::Client.new(
  :access_token => ENV['GITHUB_TOKEN']
)

#-----------------------------------------------------------------------------#
