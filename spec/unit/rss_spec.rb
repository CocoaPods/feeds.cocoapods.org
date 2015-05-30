# encoding: UTF-8
require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../../../app', __FILE__)

describe FeedsApp::RSS do

  before do
    Time.stubs(:now).returns(Time.at(0).gmtime)
    @spec = Pod::Spec.new do |spec|
      spec.name             = "FLAnimatedImage"
      spec.version          = "1.0.8"
      spec.summary          = "Performant animated GIF engine for iOS"
      spec.description      = <<-DESC
                            - Plays multiple GIFs simultaneously with a playback speed comparable to desktop browsers
                            - Honors variable frame delays
                            - Behaves gracefully under memory pressure
                            - Eliminates delays or blocking during the first playback loop
                            - Interprets the frame delays of fast GIFs the same way modern browsers do

                            It's a well-tested [component that powers all GIFs in Flipboard](http://engineering.flipboard.com/2014/05/animated-gif/).
                            DESC

      spec.homepage         = "https://github.com/Flipboard/FLAnimatedImage"
      spec.screenshots      = "https://github.com/Flipboard/FLAnimatedImage/raw/master/images/flanimatedimage-demo-player.gif"
      spec.license          = { :type => "MIT", :file => "LICENSE" }
      spec.author           = { "Raphael Schaad" => "raphael.schaad@gmail.com" }
      spec.social_media_url = "https://twitter.com/raphaelschaad"
      spec.platform         = :ios, "6.0"
      spec.source           = { :git => "https://github.com/Flipboard/FLAnimatedImage.git", :tag => "1.0.8" }
      spec.source_files     = "FLAnimatedImageDemo/FLAnimatedImage", "FLAnimatedImageDemo/FLAnimatedImage/**/*.{h,m}"
      spec.frameworks       = "QuartzCore", "ImageIO", "MobileCoreServices", "CoreGraphics"
      spec.requires_arc     = true
    end
    presenter = Pod::Specification::Set::Presenter.new FeedsApp::Controllers::WebController::SpecSet.new(@spec)
    @sut = FeedsApp::RSS.new([presenter], @spec.name => 'Sat, 30 May 2015 14:09:48 -0700')
  end

  it 'returns the correct RSS' do
    @sut.feed.should == <<-S.strip_heredoc.strip
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0"
        xmlns:content="http://purl.org/rss/1.0/modules/content/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
        xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
        <channel>
          <title>CocoaPods</title>
          <link>http://www.cocoapods.org</link>
          <description>CocoaPods new pods feed</description>
          <language>en</language>
          <lastBuildDate>Thu, 01 Jan 1970 00:00:00 -0000</lastBuildDate>
          <item>
            <title>FLAnimatedImage</title>
            <link>https://cocoapods.org/pods/FLAnimatedImage</link>
            <description>&lt;p&gt;&lt;ul&gt;
      &lt;li&gt;Plays multiple GIFs simultaneously with a playback speed comparable to desktop browsers&lt;/li&gt;
      &lt;li&gt;Honors variable frame delays&lt;/li&gt;
      &lt;li&gt;Behaves gracefully under memory pressure&lt;/li&gt;
      &lt;li&gt;Eliminates delays or blocking during the first playback loop&lt;/li&gt;
      &lt;li&gt;Interprets the frame delays of fast GIFs the same way modern browsers do&lt;/li&gt;
      &lt;/ul&gt;

      &lt;p&gt;It&amp;#39;s a well-tested &lt;a href=&quot;http://engineering.flipboard.com/2014/05/animated-gif/&quot;&gt;component that powers all GIFs in Flipboard&lt;/a&gt;.&lt;/p&gt;
      &lt;/p&gt;
      &lt;p&gt;Authored by Raphael Schaad.&lt;/p&gt;
      &lt;p&gt;[ Available at: &lt;a href=&quot;https://github.com/Flipboard/FLAnimatedImage.git&quot;&gt;https://github.com/Flipboard/FLAnimatedImage.git&lt;/a&gt; ]&lt;/p&gt;
      &lt;ul&gt;
        &lt;li&gt;Latest version: 1.0.8&lt;/li&gt;
        &lt;li&gt;Platform: iOS 6.0&lt;/li&gt;
        &lt;li&gt;Homepage: &lt;a href='https://github.com/Flipboard/FLAnimatedImage'&gt;https://github.com/Flipboard/FLAnimatedImage&lt;/a&gt;&lt;/li&gt;
        &lt;li&gt;License: MIT&lt;/li&gt;
      &lt;/ul&gt;
      &lt;img src='https://github.com/Flipboard/FLAnimatedImage/raw/master/images/flanimatedimage-demo-player.gif' style='border:1px solid #aaa;min-width:44px; min-height:44px;margin: 22px 22px 0 0; padding: 4px;box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);border: 1px solid rgba(0, 0, 0, 0.2);'&gt;
      </description>
            <pubDate>Sat, 30 May 2015 14:09:48 -0700</pubDate>
            <guid isPermaLink="false">FLAnimatedImage</guid>
            <dc:date>2015-05-30T14:09:48-07:00</dc:date>
          </item>
        </channel>
      </rss>
    S
  end
end
