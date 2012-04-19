ENV['SPECS_URL'] = 'git://github.com/CocoaPods/Specs.git'
HOOK_PATH = ENV['HOOK_PATH'] = 'secret'

require File.expand_path('../../app', __FILE__)

require 'test/unit'
require 'mocha'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

CocoaPodsNotifier::Repo.new.setup
