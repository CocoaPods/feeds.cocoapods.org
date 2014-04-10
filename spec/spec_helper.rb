require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$LOAD_PATH.unshift((ROOT + 'lib').to_s)
$LOAD_PATH.unshift((ROOT + 'spec').to_s)
$LOAD_PATH.unshift((ROOT).to_s)

ENV['SPECS_URL'] = 'git://github.com/CocoaPods/Specs.git'
ENV['RACK_ENV'] = 'test'
HOOK_PATH = ENV['HOOK_PATH'] = 'secret'
$silent = true

require 'rack/test'
require 'bundler/setup'
require 'bacon'
require 'mocha-on-bacon'
require 'spec_helper/bacon'
require 'spec_helper/http_mock'
require 'cocoapods_notifier'

REAL_REPO = CocoaPodsNotifier::Repo.new(ROOT + 'tmp/.cocoapods/master')
REAL_REPO.setup_if_needed

class Bacon::Context
  def create_fixture_repo
    repo = CocoaPodsNotifier::Repo.new(ROOT + 'spec/fixtures/master_repo')
    repo.silent = true
    repo
  end
end

Pod::Specification::Set::Statistics.instance.cache_expiration = 60 * 60 * 24 * 365
Pod::Specification::Set::Statistics.instance.cache_file = ROOT + 'caches/test-statistics.yml'
