require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../app', __FILE__)

describe 'The CocoaPods Notifier App' do
  extend Rack::Test::Methods

  def app
    CocoaPodsNotifier::App
  end

  before do
    FileUtils.rm_f app::RSS_FILE

    # Do not make any HTTP calls!
    Pod::Specification::Set::Statistics.instance.stubs(:github_stats_if_needed)
    Twitter.stubs(:tweet)
    Octokit::Client.any_instance.stubs(:repo).returns({ 'stargazers_count' => 3893 })
  end

  #---------------------------------------------------------------------------#

  it 'returns a preview of the tweets' do
    get '/'
    last_response.should.be.ok
    # last_response.body.should.include
  end

  it 'generates the RSS for the master branch' do
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/master' }.to_json
    last_response.status.should == 201
  end

  it "doesn't generate the RSS file for other branches than master" do
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/other-branch' }.to_json
    last_response.status.should == 200
    File.exist?(app::RSS_FILE).should.be.false
  end
end
