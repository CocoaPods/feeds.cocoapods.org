# encoding: UTF-8
require File.expand_path('../test_helper', __FILE__)

class TwitterTest < Test::Unit::TestCase
  def setup
    super
    set = Pod::Source.search(Pod::Dependency.new('JSONKit'))
    set.stubs(:required_version).returns(Pod::Version.new('1.4'))
    @pod = Pod::UI::UIPod.new(set)
  end

  def test_it_creates_a_tweet_for_a_new_tweet
    Twitter.expects(:update).with('[JSONKit] A Very High Performance Objective-C JSON Library. https://github.com/johnezang/JSONKit')
    CocoaPodsNotifier::Twitter.tweet(@pod)
  end

  def test_it_truncates_the_summary_if_the_complete_text_would_be_over_140_chars
    @pod.stubs(:summary).returns('This is a message which is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay ' \
                                 'too long and will get truncated here (this will be omitted).')

    expected = '[JSONKit] This is a message which is waaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay ' \
               'too long and will get truncated here… https://github.com/johnezang/JSONKit'

    # This is to correctly count (Unicode) chars on Ruby 1.8 as well.
    char_size = expected.unpack("U*").size

    # This is because the link can be any size, but will be shortened to 21 chars (because it's https).
    assert_equal 140, (char_size - @pod.homepage.size + 21)

    Twitter.expects(:update).with(expected)
    CocoaPodsNotifier::Twitter.tweet(@pod)
  end

  def perfrom_trailing_string_truncation_test (tested_string)
    name           = '[JSONKit] '
    link           = 'https://github.com/johnezang/JSONKit'
    link_length    = 21     # expected shortened https link length
    ellipsis       = '… '   # notice the space
    x_length       = 140 -
                     tested_string.length -
                     name.length -
                     link_length -
                     2 # ellipsis

    summary        = 'x' * x_length + "#{tested_string} truncated part"
    status         = name + 'x' * x_length + ellipsis + link

    @pod.stubs(:summary).returns(summary)
    Twitter.expects(:update).with(status)
    CocoaPodsNotifier::Twitter.tweet(@pod)
  end

  def test_it_removes_trailing_spaces_in_truncation
    perfrom_trailing_string_truncation_test ' '
  end

  def test_it_removes_trailing_comas_in_truncation
    perfrom_trailing_string_truncation_test ','
  end

  def test_it_removes_trailing_dots_in_truncation
    perfrom_trailing_string_truncation_test '.'
  end
end
