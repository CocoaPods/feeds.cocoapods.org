#encoding: UTF-8
require File.expand_path('../../spec_helper', __FILE__)


describe CocoaPodsNotifier::TwitterNotifier do

  before do
    @pod = create_fixture_repo.pod_named('AFNetworking')
    @twitter_client = stub()
    @sut = CocoaPodsNotifier::TwitterNotifier.new(@twitter_client)
  end

  #---------------------------------------------------------------------------#

  describe "In general" do

    it "posts a tweet for the given Pod" do
      @twitter_client.expects(:update).with('[AFNetworking by @AFNetworking] A delightful iOS and OS X networking framework. https://github.com/AFNetworking/AFNetworking')
      @sut.tweet(@pod)
    end

  end

  describe "#make_status" do

    it "generates a status for a Pod" do
      name = 'Pod'
      summary = 'A short description.'
      homepage = 'www.example.com'
      social_media_url = 'https://twitter.com/cocoapods'
      result = @sut.make_status(name, summary, homepage, social_media_url)
      result.should == "[Pod by @cocoapods] A short description. www.example.com"
    end

    it "doesn't modifies short messages" do
      result = @sut.send(:make_status, 'Pod', "A short description.", 'www.example.com', nil)
      result.should == "[Pod] A short description. www.example.com"
    end

    it "truncates a long messages" do
      summary = "A short description"
      summary << "#" * 140
      result = @sut.send(:make_status, 'Pod', summary, 'www.example.com', nil)
      result.gsub('www.example.com', '').length.should == 119
      result.should.match /\[Pod\] A short description.+ www.example.com/
    end

    describe "social media URL" do

      before do
        @name = 'Pod'
        @summary = 'A short description.'
        @homepage = 'www.example.com'
      end

      it "supports URLs with the twitter domain using the https protocol" do
        social_media_url = 'https://twitter.com/cocoapods'
        result = @sut.make_status(@name, @summary, @homepage, social_media_url)
        result.should == "[Pod by @cocoapods] A short description. www.example.com"
      end

      it "supports URLs with the twitter domain using the http protocol" do
        social_media_url = 'http://twitter.com/cocoapods'
        result = @sut.make_status(@name, @summary, @homepage, social_media_url)
        result.should == "[Pod by @cocoapods] A short description. www.example.com"
      end

      it "is not confused by URLs not relative to twitter" do
        social_media_url = 'http://facebook.com/cocoapods'
        result = @sut.make_status(@name, @summary, @homepage, social_media_url)
        result.should == "[Pod] A short description. www.example.com"
      end

      it "handles nil social media URLs" do
        result = @sut.make_status(@name, @summary, @homepage, nil)
        result.should == "[Pod] A short description. www.example.com"
      end
    end
  end

  #---------------------------------------------------------------------------#

  describe "Private Helpers" do

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
