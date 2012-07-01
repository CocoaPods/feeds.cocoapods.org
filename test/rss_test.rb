require File.expand_path('../test_helper', __FILE__)
require 'rexml/document'

class RSSTest < Test::Unit::TestCase
  def setup
    super
    unless @rss
      @sets = []
      json_kit = Pod::Source.search(Pod::Dependency.new('JSONKit'))
      json_kit.stubs(:versions).returns([Pod::Version.new('1.4')])
      @sets << json_kit
      ss_zip_archive = Pod::Source.search(Pod::Dependency.new('SSZipArchive'))
      ss_zip_archive.stubs(:versions).returns([Pod::Version.new('0.1.2')])
      @sets << ss_zip_archive

      @pods = @sets.map { |set| Pod::Command::Presenter::CocoaPod.new(set) }

      # SSZipArchive has been created most recently, so comes first
      # JSONKit has been created earlier, so comes last
      @creation_dates = {
        'JSONKit'      => Time.now - 60,
        'SSZipArchive' => Time.now - 30,
      }

      @rss   = CocoaPodsNotifier::RSS.new(@pods, @creation_dates)
      @root  = REXML::Document.new(@rss.feed).root
      item1  = @root.elements['channel/item[1]']
      item2  = @root.elements['channel/item[2]']
      @desc1 = REXML::Document.new("<root>#{item1.elements['description'].text}</root>").root
      @desc2 = REXML::Document.new("<root>#{item2.elements['description'].text}</root>").root
    end
  end

  # Check RSS Items

  def check_values(item_node)
    value1 = @root.elements["channel/item[1]/#{item_node}"].text
    value2 = @root.elements["channel/item[2]/#{item_node}"].text
    [value1, value2]
  end

  def test_it_uses_the_pod_titles_as_item_title
    value1, value2 = check_values('title')
    assert_equal value1, 'SSZipArchive'
    assert_equal value2, 'JSONKit'
  end

  def test_it_uses_the_pod_homepages_as_item_link
    value1, value2 = check_values('link')
    assert_equal value1, 'https://github.com/samsoffes/ssziparchive'
    assert_equal value2, 'https://github.com/johnezang/JSONKit'
  end

  # Check Items Descriptions

  def check_description_values(desc_node_1, desc_node_2 = nil)
    desc_node_2 = desc_node_1 unless desc_node_2
    value1 = @desc1.elements[desc_node_1].text
    value2 = @desc2.elements[desc_node_2].text
    [value1, value2]
  end

  def test_it_shows_the_pod_description
    value1, value2 = check_description_values('p[1]')
    assert_equal value1, 'SSZipArchive is a simple utility class for zipping and unzipping files on iOS and Mac.'
    assert_equal value2, 'A Very High Performance Objective-C JSON Library.'
  end

  def test_it_shows_the_pod_author
    value1 = @desc1.elements['p[2]'].to_s
    value2 = @desc2.elements['p[2]'].to_s
    assert_equal value1.to_s, "<p>Authored by Sam Soffes.</p>"
    assert_equal value2.to_s, "<p>Authored by John Engelhart.</p>"

  end

  def test_it_shows_the_repo_link
    value1 = @desc1.elements['p[3]'].to_s
    value2 = @desc2.elements['p[3]'].to_s
    assert_equal value1.to_s, "<p>[ Available at: <a href='https://github.com/samsoffes/ssziparchive.git'>https://github.com/samsoffes/ssziparchive.git</a> ]</p>"
    assert_equal value2.to_s, "<p>[ Available at: <a href='https://github.com/johnezang/JSONKit.git'>https://github.com/johnezang/JSONKit.git</a> ]</p>"
  end

  def test_it_shows_the_pod_description
    value1, value2 = check_description_values('p[1]')
    assert_equal value1, 'SSZipArchive is a simple utility class for zipping and unzipping files on iOS and Mac.'
    assert_equal value2, 'A Very High Performance Objective-C JSON Library.'
  end

  def test_it_shows_the_pod_version
    value1, value2 = check_description_values('ul/li[1]')
    assert_equal value1, "Latest version: 0.1.2"
    assert_equal value2, "Latest version: 1.4"
  end

  def test_it_shows_the_pod_platform
    value1, value2 = check_description_values('ul/li[2]')
    assert_equal value1, "Platform: iOS - OS X"
    assert_equal value2, "Platform: iOS - OS X"
  end

  def test_it_shows_the_pod_license
    value1, value2 = check_description_values('ul/li[3]')
    # SSZipArchive doesn't have a license
    assert_equal value2, "License: BSD / Apache License, Version 2.0"
  end

  def test_it_shows_the_pod_github_watchers
    value1, value2 = check_description_values('ul/li[4]', 'ul/li[4]')
    assert_match /Watchers: \d+/, value1
    assert_match /Watchers: \d+/, value2
  end

   def test_it_shows_the_pod_github_forks
    value1, value2 = check_description_values('ul/li[5]', 'ul/li[5]')
    assert_match /Forks: \d+/, value1
    assert_match /Forks: \d+/, value2
  end

  def test_it_generates_the_CocoaPods_channel
    assert_equal 'CocoaPods', @root.elements['channel/title'].text
  end
end
