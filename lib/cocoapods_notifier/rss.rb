require 'rss/maker'
require 'redcarpet'
require 'cocoapods_notifier/html_helpers'

module FeedsApp
  # Creates the RSS feed.
  #
  class RSS
    # @return [Array<Pod::Specification::Set::Presenter>] The list of all the
    #         Pods available in the master repo.
    #
    attr_reader :pods

    # @return [Hash{String => Time}] The date in which the first podspec of
    #         each Pod appeared for the first time in the master repo.
    #
    attr_reader :creation_dates

    # @param [Array<Pod::Specification::Set::Presenter>] @see pods
    # @param [Hash{String => Time}] @see creation_dates
    #
    def initialize(pods, creation_dates)
      @pods = pods
      @creation_dates = creation_dates
    end

    # @return [String] The contents of the RSS feed.
    #
    def feed
      rss = ::RSS::Maker.make('2.0') do |m|
        # m.xml_stylesheets.new_child.href = "rss.css"
        m.channel.title         = 'CocoaPods'
        m.channel.link          = 'http://www.cocoapods.org'
        m.channel.description   = 'CocoaPods new pods feed'
        m.channel.language      = 'en'
        m.channel.lastBuildDate = Time.now
        m.items.do_sort         = true
        pods_for_feed.each do |pod|
          configure_rss_item(m.items.new_item, pod)
        end
      end
      rss.to_s
    end

    # @return [Array<Pod::Specification::Set::Presenter>] The list of the 30
    #         most recent pods sorted from newest to oldest.
    #
    def pods_for_feed
      pods
    end

    private

    # Private Helpers
    #-------------------------------------------------------------------------#

    # Configures a new RSS item with the given Pod.
    #
    # @param  [Pod::Specification::Set::Presenter] The pod corresponding to the
    #         item.
    #
    # @return [void]
    #
    def configure_rss_item(item, pod)
      item.title        = pod.name
      item.link         = "https://cocoapods.org/pods/#{pod.name}"
      item.pubDate      = @creation_dates[pod.name]
      item.description  = rss_item_description(pod)
      item.guid.content = pod.name
      item.guid.isPermaLink = false
    end

    # Returns the HTML description of the RSS item corresponding to the given
    # Pod.
    #
    # @param  [Pod::Specification::Set::Presenter] The pod to describe.
    #
    # @return [String] the description for the RSS item.
    #
    def rss_item_description(pod)
      s =  "<p>#{markdown(pod.description)}</p>"
      s << "\n<p>Authored by #{pod.authors}.</p>"
      s << "\n<p>[ Available at: <a href=\"#{pod.source_url}\">#{pod.source_url}</a> ]</p>"
      s << "\n<ul>"
      s << "\n  <li>Latest version: #{pod.version}</li>"
      s << "\n  <li>Platform: #{pod.platform}</li>"
      s << "\n  <li>Homepage: <a href='#{pod.homepage}'>#{pod.homepage}</a></li>"
      s << "\n  <li>License: #{pod.license}</li>" if pod.license
      s << "\n</ul>"

      pod.spec.screenshots.compact.each do |screenshot_url|
        style =  'border:1px solid #aaa;'
        style << 'min-width:44px; min-height:44px;'
        style << 'margin: 22px 22px 0 0; padding: 4px;'
        style << 'box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);'
        style << 'border: 1px solid rgba(0, 0, 0, 0.2);'
        s << "\n<img src='#{screenshot_url}' style='#{style}'>"
      end
      s << "\n"
    end

    # @param  [String]
    # @return [String]
    #
    def markdown(input)
      markdown_renderer.render(input)
    end

    # @return [Redcarpet::Markdown]
    #
    def markdown_renderer
      @markdown_instance ||= Redcarpet::Markdown.new(Class.new(Redcarpet::Render::HTML) do
        def block_code(code, lang)
          lang ||= 'ruby'
          HTMLHelpers.syntax_highlight(code, :language => lang)
        end
      end, :autolink => true, :space_after_headers => true, :no_intra_emphasis => true)
    end

    #-------------------------------------------------------------------------#
  end
end
