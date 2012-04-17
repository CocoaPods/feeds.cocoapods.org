require "twitter"

Twitter.configure do |config|
  config.consumer_key       = ENV['CONSUMER_KEY']
  config.consumer_secret    = ENV['CONSUMER_SECRET']
  config.oauth_token        = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end

class CocoapodFeed
  class PodTwitter
    def self.tweet(pod)
      intro       = "[New] #{pod.name} - "
      link_lenght = 21 + 1
      available   = 140 - intro.length - link_lenght
      if pod.summary.length > available
        summary = pod.summary[0..available-4].gsub(/('s)?( )?$/,'') + '...'
      else
        summary = pod.summary
      end
      link = " #{pod.homepage}"
      text = intro + summary + link
      Twitter.update(text)
    rescue StandardError => e
      puts "[!] Tweet failed - #{e.message}".red
    end
  end
end
