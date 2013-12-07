require File.expand_path('../../spec_helper', __FILE__)

describe CocoaPodsNotifier::Repo do

  before do
    @fixture_repo = create_fixture_repo
  end

  describe "In general" do

    it "returns the directory of the master repo" do
      @fixture_repo.master_repo_dir.class.should == Pathname
      @fixture_repo.master_repo_dir.to_s.should.end_with('spec/fixtures/master_repo')
    end

  end

  #---------------------------------------------------------------------------#

  describe "Pods" do

    it "returns the list of the available sets" do
      sets = @fixture_repo.sets
      sets.map(&:class).uniq.should == [Pod::Specification::Set]
      sets.map(&:name).should.include('AFNetworking')
    end

    it "returns the list of the Pod presenters" do
      pods = @fixture_repo.pods
      pods.map(&:class).uniq.should == [Pod::Specification::Set::Presenter]
      pods.map(&:name).should.include('AFNetworking')
    end

    it "returns the presenter for the Pod with the given name" do
      pod = @fixture_repo.pod_named('AFNetworking')
      pod.name.should == 'AFNetworking'
      pod.summary.should == 'A delightful iOS and OS X networking framework.'
    end

    it "returns the creation dates of the Pods" do
      @fixture_repo.creation_dates['AFNetworking'].should == Time.parse('2011-09-18 21:2:31 +02:00')
    end

  end

  #---------------------------------------------------------------------------#

  describe "Initialization & Update" do

    it "sets up the master repo if the directory doesn't exists" do
      @fixture_repo.stubs(:master_repo_url).returns(ROOT + 'spec/fixtures/master_repo')
      @fixture_repo.setup_if_needed
      test_path = @fixture_repo.master_repo_dir + 'AFNetworking/1.2.0/AFNetworking.podspec'
      test_path.should.exist
    end

    it "skips the setup of the master repo if the directory exists" do
      @fixture_repo.expects(:git).never
      @fixture_repo.setup_if_needed
    end

    it "updates the master repo against its remote" do
      @fixture_repo.expects(:git).with("pull", @fixture_repo.master_repo_dir)
      @fixture_repo.update
    end

    it "returns the list of pods added after an update" do
      @fixture_repo.setup_if_needed
      Dir.chdir(@fixture_repo.master_repo_dir) { `git checkout 9235af8 > /dev/null 2>&1` }
      def @fixture_repo.git(command, dir = Dir.pwd)
        Dir.chdir(master_repo_dir) do
          `git checkout 406cc94 > /dev/null 2>&1`
        end
      end
      @fixture_repo.update
      Dir.chdir(@fixture_repo.master_repo_dir) { `git checkout master > /dev/null 2>&1` }
      @fixture_repo.new_pod_names.should == ["StateMachine-GCDThreadsafe", "TMTumblrSDK", "iOS-GTLYouTube"]
    end

  end

  #---------------------------------------------------------------------------#

end
