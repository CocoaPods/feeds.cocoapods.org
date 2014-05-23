require 'app/controllers/base_controller.rb'

require 'exceptio-ruby'
require 'colored'
require 'cocoapods-core'
require 'slim'
require 'cocoapods_notifier'

module FeedsApp
  module Controllers
    # App which handles all web pages.
    #
    class WebController < BaseController
      # Redirect to URLs without the final slash.
      #
      get %r{^(/.+)/$} do
        redirect params[:captures].first
      end

      # The homepage
      #
      get '/' do
        pods = Models::Pod.all
        @pods_count = pods.length
        @last_12h_pods = []
        @last_24h_pods = []
        @last_48h_pods = []
        limit_12h = Time.now - 60 * 60 * 12
        limit_24h = Time.now - 60 * 60 * 24
        limit_48h = Time.now - 60 * 60 * 48
        pods = pods.sort_by { |pod| pod.creation_date }.reverse
        pods.each do |pod|
          if pod.creation_date > limit_12h
            @last_12h_pods << pod
          elsif pod.creation_date > limit_24h
            @last_24h_pods << pod
          elsif pod.creation_date > limit_48h
            @last_48h_pods << pod
          end
        end

        slim :index
      end
    end
  end
end


