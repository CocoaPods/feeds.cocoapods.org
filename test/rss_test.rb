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

      @creation_dates = {
        'JSONKit'      => Time.now - 60,
        'SSZipArchive' => Time.now - 30,
      }

      @rss = CocoapodFeed::Rss.new(@pods, @creation_dates)
      @root = REXML::Document.new(@rss.feed).root
    end
  end

  # TODO this needs to be refactored to test smaller units
  #
  # E.g.
  #
  # def test_it_uses_the_pod_titles_as_item_title
  #   assert_equal 'SSZipArchive', @root.elements['channel/item[1]/title'].text
  #   assert_equal 'JSONKit',      @root.elements['channel/item[2]/title'].text
  # end

  def test_it_generates_a_rss_document
    root = @root
    assert_equal 'CocoaPods', root.elements['channel/title'].text

    # SSZipArchive has been created most recently, so comes first
    item = root.elements['channel/item[1]']
    assert_equal 'SSZipArchive', item.elements['title'].text
    homepage = 'https://github.com/samsoffes/ssziparchive'
    assert_equal homepage, item.elements['link'].text
    description = REXML::Document.new("<root>#{item.elements['description'].text}</root>").root
    assert_equal 'SSZipArchive is a simple utility class for zipping and unzipping files on iOS and Mac.', description.elements['p[1]'].text
    assert_equal "<p>[ by Sam Soffes | available at: <a href='#{homepage}.git'>github.com</a> ]</p>", description.elements['p[2]'].to_s
    assert_equal "Latest version: 0.1.2", description.elements['ul/li[1]'].text
    assert_equal "Platform: iOS - OS X", description.elements['ul/li[2]'].text
    assert_match /Watchers: \d+/, description.elements['ul/li[3]'].text
    assert_match /Forks: \d+/, description.elements['ul/li[4]'].text

    # JSONKit has been created earlier, so comes last
    item = root.elements['channel/item[2]']
    assert_equal 'JSONKit', item.elements['title'].text
    homepage = 'https://github.com/johnezang/JSONKit'
    assert_equal homepage, item.elements['link'].text
    description = REXML::Document.new("<root>#{item.elements['description'].text}</root>").root
    assert_equal 'A Very High Performance Objective-C JSON Library.', description.elements['p[1]'].text
    assert_equal "<p>[ by John Engelhart | available at: <a href='#{homepage}.git'>github.com</a> ]</p>", description.elements['p[2]'].to_s
    assert_equal "Latest version: 1.4", description.elements['ul/li[1]'].text
    assert_equal "Platform: iOS - OS X", description.elements['ul/li[2]'].text
    assert_equal "License: BSD / Apache License, Version 2.0", description.elements['ul/li[3]'].text
    assert_match /Watchers: \d+/, description.elements['ul/li[4]'].text
    assert_match /Forks: \d+/, description.elements['ul/li[5]'].text
  end
end
