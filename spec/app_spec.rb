require File.expand_path('../spec_helper', __FILE__)

ENV['SPECS_URL'] = 'git://github.com/CocoaPods/Specs.git'
ENV['RACK_ENV'] = 'test'
HOOK_PATH = ENV['HOOK_PATH'] = 'secret'
$silent = true

require 'rack/test'
require File.expand_path('../../app', __FILE__)

describe 'The CocoaPods Notifier App' do
  extend Rack::Test::Methods

  def app
    CocoaPodsNotifier::CocoaPodsNotifierApp
  end

  before do
    FileUtils.rm_f app::RSS_FILE
    Twitter.stubs(:tweet)
  end

  it "returns a preview of the tweets" do
    get '/'
    last_response.should.be.ok
    # last_response.body.should.include
  end

  it "generates the RSS for the master branch" do
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/master' }.to_json
    last_response.status.should == 201
  end

  it "doesn't generate the RSS file for other branches than master" do
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/other-branch' }.to_json
    last_response.status.should == 200
    File.exist?(app::RSS_FILE).should.be.false
  end
end
