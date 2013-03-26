require 'pathname'
ROOT = Pathname.new(File.expand_path('../../', __FILE__))
$:.unshift((ROOT + 'lib').to_s)
$:.unshift((ROOT + 'spec').to_s)

require 'bundler/setup'
require 'bacon'
require 'mocha-on-bacon'
require 'spec_helper/bacon'
require 'cocoapods_notifier'

def fixutre_repo
  CocoaPodsNotifier::Repo.new(ROOT + 'spec/fixtures/master_repo')
end

fixutre_repo.setup_if_needed

