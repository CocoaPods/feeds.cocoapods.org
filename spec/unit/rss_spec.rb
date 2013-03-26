require File.expand_path('../../spec_helper', __FILE__)
require 'rexml/document'

describe CocoaPodsNotifier::RSS do

  before do
    repo = fixutre_repo
    @af_netowrking = repo.pod_named('AFNetworking')
    @mb_progress_hud = repo.pod_named('MBProgressHUD')
    pods = [@af_netowrking, @mb_progress_hud]
    creation_dates = {
      'AFNetworking'  => Time.parse('2012-01-01'),
      'MBProgressHUD' => Time.parse('2012-01-02')
    }
    @sut = CocoaPodsNotifier::RSS.new(pods, creation_dates)
  end

  #---------------------------------------------------------------------------#

  describe "In general" do

    it "returns the RSS feed" do
      feed = REXML::Document.new(@sut.feed).root
      feed.elements['channel/title'].text.should == 'CocoaPods'
      feed.elements['channel/link'].text.should == 'http://www.cocoapods.org'
      feed.elements['channel/description'].text.should == 'CocoaPods new pods feed'
      feed.elements['channel/language'].text.should == 'en'
      feed.elements['channel/item[1]/title'].text.should == 'MBProgressHUD'
      feed.elements['channel/item[2]/title'].text.should == 'AFNetworking'
    end

  end

  #---------------------------------------------------------------------------#

  describe "Private Helpers" do

    describe "#pods_for_feed" do

      it "returns the list of the Pods to include in the feed" do
        @sut.send(:pods_for_feed).map(&:name).sort.should == ["AFNetworking", "MBProgressHUD"]
      end

      it "it sorts the Pods from newest to oldest" do
        @sut.send(:pods_for_feed).map(&:name).should == ["MBProgressHUD", "AFNetworking"]
      end

    end

    #--------------------------------------#

    describe "#configure_rss_item" do

      before do
        rss = ::RSS::Maker.make('2.0') do |rss|
          rss.channel.title         = "CocoaPods"
          rss.channel.link          = "http://www.cocoapods.org"
          rss.channel.description   = "CocoaPods new added pods feed"
          @item = rss.items.new_item
        end
        @sut.send(:configure_rss_item, @item, @af_netowrking)
      end

      it "uses the name of the Pod as the item title" do
        @item.title.should == 'AFNetworking'
      end

      it "uses the Pod homepage as the item link" do
        @item.link.should == 'https://github.com/AFNetworking/AFNetworking'
      end

      it "uses the creation date of the Pod as the item publication date" do
        @item.pubDate.should == Time.new(2012, 01, 01)
      end

      it "uses the description of the Pod as the item description" do
        @item.description.should.match /A delightful iOS and OS X networking framework/
      end

    end

    #--------------------------------------#

    describe "#rss_item_description" do

      before do
        @desc = @sut.send(:rss_item_description, @af_netowrking)
      end

      it "includes the description" do
        @desc.should.include('<p>A delightful iOS and OS X networking framework.</p>')
      end

      it "includes the list of the authors" do
        @desc.should.include('<p>Authored by Mattt Thompson and Scott Raymond.</p>')
      end

      it "includes the link to the source" do
        @desc.should.include('<p>[ Available at: <a href="https://github.com/AFNetworking/AFNetworking.git">https://github.com/AFNetworking/AFNetworking.git</a> ]</p>')
      end

      it "includes the latest version" do
        @desc.should.include('<li>Latest version: 1.2.0</li>')
      end

      it "includes the latest platforms" do
        @desc.should.include('<li>Platform: iOS 5.0 - OS X 10.7</li>')
      end

      it "includes the license" do
        @desc.should.include('<li>License: MIT</li>')
      end

      it "includes the github stargazers" do
        @desc.should.match(/<li>Stargazers: .*<\/li>/)
      end

      it "includes the github forks" do
        @desc.should.match(/<li>Forks: .*<\/li>/)
      end

    end

    #--------------------------------------#

  end

  #---------------------------------------------------------------------------#

end
