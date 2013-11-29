#encoding: UTF-8
require File.expand_path('../../spec_helper', __FILE__)


describe CocoaPodsNotifier::TwitterNotifier do

  before do
    repo = CocoaPodsNotifier::Repo.new(ROOT + 'tmp/.cocoapods/master')
    @pod = repo.pod_named('AFNetworking')
    @twitter_client = stub()
    @sut = CocoaPodsNotifier::TwitterNotifier.new(@twitter_client)
  end

  #---------------------------------------------------------------------------#

  describe "In general" do

    it "posts a tweet for the given Pod" do
      @twitter_client.expects(:update).with('[AFNetworking] A delightful iOS and OS X networking framework. https://github.com/AFNetworking/AFNetworking')
      @sut.tweet(@pod)
    end

  end

  #---------------------------------------------------------------------------#

  describe "Private Helpers" do

    describe "#message_for_pod" do

      it "doesn't modifies short messages" do
        result = @sut.send(:message_for_pod, 'Pod', "A short description.", 'www.example.com')
        result.should == "[Pod] A short description. www.example.com"
      end

      it "truncates a long messages" do
        pod_summary = "A short description"
        pod_summary << "#" * 140
        result = @sut.send(:message_for_pod, 'Pod', pod_summary, 'www.example.com')
        result.gsub('www.example.com', '').length.should == 119
        result.should.match /\[Pod\] A short description.+ www.example.com/
      end

    end

    #--------------------------------------#

    describe "#truncate_message" do

      it "truncates a message to the given length" do
        message = 'A delightful long description.'
        result = @sut.send(:truncate_message, message, 10, '...')
        result.should == 'A delig...'
        result.length.should == 10
      end

      it "strip trailing white spaces" do
        message = 'A long description.'
        result = @sut.send(:truncate_message, message, 10, '...')
        result.should == 'A long...'
        result.length.should == 9
      end

      it "strip trailing dots" do
        message = 'A long. Description.'
        result = @sut.send(:truncate_message, message, 10, '...')
        result.should == 'A long...'
        result.length.should == 9
      end

      it "strip trailing comas" do
        message = 'A long. Description.'
        result = @sut.send(:truncate_message, message, 10, '...')
        result.should == 'A long...'
        result.length.should == 9
      end

    end

    #--------------------------------------#

    describe "#message_max_length" do

      it "returns the maximum length available for the description excluding the link" do
        @sut.send(:message_max_length).should == 118
      end

    end

    #--------------------------------------#

  end

  #---------------------------------------------------------------------------#

end
