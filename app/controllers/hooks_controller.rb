require 'app/controllers/base_controller'

module FeedsApp
  module Controllers
    class HooksController < BaseController
      # The hook to trigger the update for a Pod with the given name
      #
      post "/hook" do
        200
      end

      # Sends the tweets for the Pods with the missing name.
      #
      def send_missing_tweets
        pods = Models::Pod[:tweet_sent => false]
        pods.each do |pod|
          spec = spec_for_pod(pod)
          TwitterNotifier.new.tweet(spec)
        end
      end

      # The path of the RSS file. Served statically as it is located in the public
      # folder.
      #
      RSS_FILE = File.join(ROOT, 'public/new-pods.rss')

      def generate_rss_file
        feed = RSS.new(master_repo.pods, master_repo.creation_dates).feed
        File.open(RSS_FILE, 'w') { |f| f.write(feed) }
      end

      def spec_for_pod(pod)
        nil
        # TODO: Use CocoaPods-Core Github data provider
      end

    end
  end
end
