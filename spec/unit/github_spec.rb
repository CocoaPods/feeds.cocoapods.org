require File.expand_path('../../spec_helper', __FILE__)

describe CocoaPodsNotifier::GitHub do

  before do
    @subject = CocoaPodsNotifier::GitHub
  end

  it 'fetches the stargazers count of a repo' do
    url = 'http://github.com/CocoaPods/CocoaPods.git'
    response = { 'stargazers_count' => 3893 }
    Octokit::Client.any_instance.expects(:repo).with('CocoaPods/CocoaPods')
      .returns(response)
    count = @subject.get_stargazer_count(url)
    count.should == 3893
  end

  it 'handles sources without a github url' do
    url = 'http://example.com/CocoaPods/CocoaPods'
    count = @subject.get_stargazer_count(url)
    count.should.be.nil
  end

  it 'returns nil if the url could not be found' do
    url = 'http://github.com/CocoaPods/not_found'
    Octokit::Client.any_instance.expects(:repo).with('CocoaPods/not_found')
      .raises(Octokit::NotFound)
    count = @subject.get_stargazer_count(url)
    count.should.be.nil
  end

end
