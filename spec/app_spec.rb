require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../app', __FILE__)

describe 'The CocoaPods Notifier App' do
  extend Rack::Test::Methods

  def app
    FeedsApp::App
  end

  it 'returns a preview of the tweets' do
    get '/'
    last_response.should.be.ok
  end

end
