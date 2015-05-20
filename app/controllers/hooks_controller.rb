require 'app/controllers/base_controller'
require 'rest'
require 'json'
require 'cocoapods-core'

module FeedsApp
  module Controllers
    class HooksController < BaseController
      # The hook to trigger the update for a Pod with the given name
      #
      # post "/hook" do
      get "/:name" do |name|
        # { type: 'commit', created_at: <date>, data_url: <URL> }
        # body = request.body.read
        # json = JSON.parse(body)

        pod = Models::Pod.find_or_create(:name => name)
        pod.spec = spec_for_pod(name)
        pod.created_at = Date.new
        pod.save
        
        # send_missing_tweets
        200
      end
      
      trunk_notification_path = ENV['TRUNK_NOTIFICATION_PATH']
      trunk_notification_path ||= ARGV[0]
      abort "You need to give a Trunk webhook URL" unless trunk_notification_path

      post "/trunk/" + trunk_notification_path do
        data = JSON.parse(request.body.read)
        puts "Got a webhook notification: " + data["type"] + " - " + data["action"]

        spec_string = perform_request(data["data_url"])
        spec_json = JSON.parse(spec_string)

        pod = Models::Pod.find_or_create(:name => spec_json["name"])
        pod.spec = spec_string
        pod.created_at = Date.new
        pod.save
                
        "{ success: true }"
      end


      # @return [String] or nil
      #
      def spec_for_pod(name)
        trunk_spec = REST.get "https://trunk.cocoapods.org/api/v1/pods/#{name}"
        versions = JSON.parse(trunk_spec.body)["versions"]
        versions = versions.map { |s| Pod::Version.new(s["name"]) }.sort.map { |semver| semver.version }

        spec_url = "https://raw.githubusercontent.com/CocoaPods/Specs/master/Specs/#{ name }/#{ versions[-1] }/#{ name }.podspec.json"
        perform_request(spec_url).to_s
      end

      def creation_date_pod(name)
        url = "https://trunk.cocoapods.org/api/v1/pods/#{name}"
        data = perform_request(url)
        data['versions'].map  { |s| Pod::Version.new(s["name"]) }.sort.map { |semver| semver.version }.last
      end

      def perform_request(url)
        headers = { 'User-Agent' => 'CocoaPods Feeds App' }
        response = REST.get(url, headers)
        data = JSON.parse(response.body)
        if response.ok?
          data
        end
      end

      # Sends the tweets for the Pods with the missing name.
      #
      def send_missing_tweets
        pods = Models::Pod[:tweet_sent => false]
        pods.each do |pod|
          TwitterNotifier.new.tweet(pod.spec)
          pod.tweet_sent = true
          pod.save
        end
      end
    end
  end
end
