
#-- Octokit ------------------------------------------------------------------#

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
  :client_id     => ENV['GITHUB_CLIENT_ID'],
  :client_secret => ENV['GITHUB_CLIENT_SECRET']
)

#-----------------------------------------------------------------------------#
