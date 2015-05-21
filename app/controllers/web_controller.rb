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
                
        @last_12h_pods = DB.fetch(query("0", "12 HR")).to_a
        @last_24h_pods = DB.fetch(query("12 HR", "24 HR")).to_a
        @last_48h_pods = DB.fetch(query("24 HR", "48 HR")).to_a
        
        slim :index
      end

      get '/new-pods.rss' do
        RSS.new(master_repo.pods, master_repo.creation_dates).feed
      end
    
      def query before_date, after_date
        query_format = <<-eos
          SELECT * FROM pods
          INNER JOIN pod_versions ON pods.id=pod_versions.pod_id 
          INNER JOIN commits ON pod_versions.id = commits.pod_version_id
          WHERE pods.created_at BETWEEN NOW() - '__AFTER_DATE__'::INTERVAL AND NOW() - '__BEFORE_DATE__'::INTERVAL
          AND pods.deleted IS FALSE  
          ORDER BY pods.created_at DESC
        eos
      
        query_format.gsub("__BEFORE_DATE__", before_date).gsub("__AFTER_DATE__", after_date.to_s)
      end
    end
  end
end
