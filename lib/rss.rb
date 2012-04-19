require 'rss/maker'

class CocoaPodsAppriser
  class RSS
    def initialize (pods, creation_dates)
      @pods = pods
      @creation_dates = creation_dates
    end

    def feed_pods
      @pods.sort_by { |pod| @creation_dates[pod.name] }.reverse[0..29]
    end

    def feed
      rss = ::RSS::Maker.make('2.0') do |m|
        m.channel.title         = "CocoaPods"
        m.channel.link          = "http://www.cocoapods.org"
        m.channel.description   = "CocoaPods new added pods feed"
        m.channel.language      = "en"
        m.channel.lastBuildDate = Time.now
        m.items.do_sort         = true

        feed_pods.each { |pod| configure_item(m.items.new_item, pod) }
      end
      rss.to_s
    end

    def configure_item(item, pod)
      item.title        = pod.name
      item.link         = pod.homepage
      item.pubDate      = @creation_dates[pod.name]
      item.description  = item_description(pod)
    rescue
      puts "[!] Malformed pod #{pod.name}".red
    end

    def item_description(pod)
      s =  "<p>#{pod.description}</p>"
      s << "<p>[ by #{pod.authors} | available at: <a href=\"#{pod.source_url}\">#{URI.parse(pod.source_url).host}</a> ]</p>"
      s << "<ul>"
      s << "<li>Latest version: #{pod.version}</li>"
      s << "<li>Platform: #{pod.platform}</li>"
      s << "<li>License: #{pod.license}</li>"          if pod.license
      s << "<li>Watchers: #{pod.github_watchers}</li>" if pod.github_watchers
      s << "<li>Forks: #{pod.github_forks}</li>"       if pod.github_forks
      s << "</ul>"
    end
  end
end
