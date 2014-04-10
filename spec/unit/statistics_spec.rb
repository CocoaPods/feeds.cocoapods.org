require File.expand_path('../../spec_helper', __FILE__)

describe CocoaPodsNotifier::Statistics do

  before do
    @subject = CocoaPodsNotifier::Statistics
    repo = create_fixture_repo
    @pod = repo.pod_named('AFNetworking')
  end

  it 'fetches the stargazers count of a pod' do
    url = 'https://github.com/AFNetworking/AFNetworking.git'
    CocoaPodsNotifier::GitHub.expects(:get_stargazer_count)
      .with(url, OCTOKIT_CLIENT).returns(100)
    result = @subject.get_stargazer_count(@pod)
    result.should == 100
  end

  it 'is robust against pods without git sources' do
    @pod.spec.source = { :svn => 'example.com' }
    @subject.get_stargazer_count(@pod).should.be.nil
  end

end

