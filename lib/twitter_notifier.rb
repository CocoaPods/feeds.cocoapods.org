# encoding: UTF-8
require "twitter"

Twitter.configure do |config|
  config.consumer_key       = ENV['CONSUMER_KEY']
  config.consumer_secret    = ENV['CONSUMER_SECRET']
  config.oauth_token        = ENV['OAUTH_TOKEN']
  config.oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
end

class CocoaPodsNotifier
  class Twitter
    # Twitter shortens urls to 20 characters
    # for http and 21 for https
    #
    MAX_LENGTH = 140 - 1 - 21

    def self.tweet(pod)
      status = status(pod) << " #{pod.homepage}"
      ::Twitter.update(status)
    end

    def self.status(pod)
      text = "[#{pod.name}] #{pod.summary}"
      text << '.' unless text =~ /\.$/
      chars = text.scan(/./mu)
      if chars.length >= MAX_LENGTH
        text = chars[0..MAX_LENGTH-2].join.gsub(/( )?\.?,?$/,'') + '…'
      end
      text
    end
  end
end
