# encoding: UTF-8
require File.expand_path('../test_helper', __FILE__)

class PodTwitterTest < Test::Unit::TestCase
  def setup
    super
    set = Pod::Source.search(Pod::Dependency.new('JSONKit'))
    set.stubs(:required_version).returns(Pod::Version.new('1.4'))
    @pod = Pod::Command::Presenter::CocoaPod.new(set)
  end

  def test_it_creates_a_tweet_for_a_new_tweet
    Twitter.expects(:update).with('[New] JSONKit - A Very High Performance Objective-C JSON Library. https://github.com/johnezang/JSONKit')
    CocoapodFeed::PodTwitter.tweet(@pod)
  end

  def test_it_truncates_the_summary_if_the_complete_text_would_be_over_140_chars
    @pod.stubs(:summary).returns('This is a message which is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay ' \
                                 'too long and will get truncated here (this will be omitted).')

    expected = '[New] JSONKit - This is a message which is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay ' \
               'too long and will get truncated here… https://github.com/johnezang/JSONKit'

    # This is because the link can be any size, but will be shortened to 21 chars (with a leading space).
    assert_equal 140, (expected.size - @pod.homepage.size + 20)

    Twitter.expects(:update).with(expected)
    CocoapodFeed::PodTwitter.tweet(@pod)
  end
end
