ENV['SPECS_URL'] = 'git://github.com/CocoaPods/Specs.git'
HOOK_PATH = ENV['HOOK_PATH'] = 'secret'

require File.expand_path('../../app', __FILE__)

require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

CocoapodFeed::Repo.new.setup

class FeedTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def teardown
    super
    #puts last_response.errors
    FileUtils.rm_f CocoapodFeed::RSS_FILE
  end

  def app
    CocoapodFeed
  end

  def test_it_generates_the_rss_file
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/master' }.to_json
    assert_equal 201, last_response.status
  end

  def test_it_does_not_generate_the_rss_file_for_other_branches_than_master
    post "/#{HOOK_PATH}", :payload => { 'ref' => 'refs/heads/other-branch' }.to_json
    assert_equal 200, last_response.status
  end

end
