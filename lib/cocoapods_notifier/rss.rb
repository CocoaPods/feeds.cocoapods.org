require 'rss/maker'

module CocoaPodsNotifier

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
    def initialize (pods, creation_dates)
      @pods = pods
      @creation_dates = creation_dates
    end

    # @return [String] The contents of the RSS feed.
    #
    def feed
      rss = ::RSS::Maker.make('2.0') do |m|
        m.channel.title         = "CocoaPods"
        m.channel.link          = "http://www.cocoapods.org"
        m.channel.description   = "CocoaPods new pods feed"
        m.channel.language      = "en"
        m.channel.lastBuildDate = Time.now
        m.items.do_sort         = true

        pods_for_feed.each { |pod| configure_rss_item(m.items.new_item, pod) }
      end
      rss.to_s
    end

    # @return [Array<Pod::Specification::Set::Presenter>] The list of the 30
    #         most recent pods sorted from newest to oldest.
    #
    def pods_for_feed
      pods.sort_by { |pod| creation_dates[pod.name] }.reverse[0..29]
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
      item.link         = pod.homepage
      item.pubDate      = @creation_dates[pod.name]
      item.description  = rss_item_description(pod)
    end

    # Returns the HTML description of the RSS item corresponding to the given
    # Pod.
    #
    # @param  [Pod::Specification::Set::Presenter] The pod to describe.
    #
    # @return [String] the description for the RSS item.
    #
    def rss_item_description(pod)
      s =  "<p>#{pod.description.gsub(/\n/, "<br>")}</p>"
      s << "<p>Authored by #{pod.authors}.</p>"
      s << "<p>[ Available at: <a href=\"#{pod.source_url}\">#{pod.source_url}</a> ]</p>"
      s << "<ul>"
      s << "<li>Latest version: #{pod.version}</li>"
      s << "<li>Platform: #{pod.platform}</li>"
      s << "<li>License: #{pod.license}</li>" if pod.license
      s << "<li>Stargazers: #{pod.github_watchers}</li>" if pod.github_watchers
      s << "<li>Forks: #{pod.github_forks}</li>" if pod.github_forks
      s << "</ul>"
    end
  end
end
