require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$LOAD_PATH.unshift((ROOT + 'lib').to_s)
$LOAD_PATH.unshift((ROOT + 'spec').to_s)
$LOAD_PATH.unshift((ROOT).to_s)

ENV['RACK_ENV'] = 'test'
HOOK_PATH = ENV['HOOK_PATH'] = 'secret'
$silent = true

require 'rack/test'
require 'bundler/setup'
require 'bacon'
require 'pretty_bacon'
require 'mocha-on-bacon'
require 'spec_helper/http_mock'
