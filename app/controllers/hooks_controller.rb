require 'app/controllers/base_controller'
require 'rest'
require 'json'
require 'cocoapods-core'

module FeedsApp
  module Controllers
    class HooksController < BaseController
      
      # The hook to trigger the tweet for a Pod with the given name
      
      trunk_notification_path = ENV['TRUNK_NOTIFICATION_PATH']
      trunk_notification_path ||= ARGV[0]
      abort "You need to give a Trunk webhook URL" unless trunk_notification_path

      post "/trunk/" + trunk_notification_path do
        data = JSON.parse(request.body.read)
        puts "Got a webhook notification: " + data["type"] + " - " + data["action"]

        spec_string = perform_request(data["data_url"])
        pod = Pod::Specification.from_json spec_string
        TwitterNotifier.new.tweet(pod)
                        
        "{ success: true }"
      end
      
      def perform_request(url)
        headers = { 'User-Agent' => 'CocoaPods Feeds App' }
        response = REST.get(url, headers)
        if response.ok?
          response.body
        end
      end

    end
  end
end
