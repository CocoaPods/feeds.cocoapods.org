# encoding: UTF-8
require "twitter"

Twitter.configure do |config|
  config.consumer_key       = ENV['CONSUMER_KEY']
  config.consumer_secret    = ENV['CONSUMER_SECRET']
  config.oauth_token        = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end

class CocoaPodsAppriser
  class Twitter
    # Twitter shortens urls to 20 characters
    # for http and 21 for https
    #
    MAX_LENGTH = 140 - 1 - 21

    def self.tweet(pod)
      status = status(pod) << " #{pod.homepage}"
      ::Twitter.update(status)
    rescue StandardError => e
      puts "[!] Tweet failed - #{e.message}".red
    end

    def self.status(pod)
      text = "[#{pod.name}] #{pod.summary}"
      text << '.' unless text =~ /\.$/
      if text.length >= MAX_LENGTH
        text = text[0..MAX_LENGTH-2].gsub(/( )?\.?,?$/,'') + '…'
      end
      text
    end
  end
end
