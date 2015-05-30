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

      SpecSet = Struct.new(:specification)

      class SpecSet
        def name
          specification.name
        end
        def versions
          [specification.version]
        end
      end

      get '/new-pods.rss' do
        pods = DB.fetch(query("0", "168 HR"))
        creation_dates = {}
        pods = pods.map do |pod|
          spec = Pod::Specification.from_json(pod[:specification_data])
          creation_dates[spec.name] = pod[:created_at]
          set = SpecSet.new(spec)
          Pod::Specification::Set::Presenter.new(set)
        end

        content_type :rss
        RSS.new(pods, creation_dates).feed
      end

      TIME_QUERY = <<-QUERY.freeze
        SELECT DISTINCT ON (pods.name, pods.created_at) * FROM pods
        INNER JOIN pod_versions ON pods.id=pod_versions.pod_id
        INNER JOIN commits ON pod_versions.id = commits.pod_version_id
        WHERE pods.created_at BETWEEN NOW() - '%{after_date}'::INTERVAL AND NOW() - '%{before_date}'::INTERVAL
        AND pods.deleted IS FALSE
        ORDER BY pods.created_at DESC
      QUERY

      def query before_date, after_date
        TIME_QUERY % { before_date: before_date, after_date: after_date }
      end
    end
  end
end
