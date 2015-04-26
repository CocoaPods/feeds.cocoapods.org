module FeedsApp
  module Models
    class Pod < Sequel::Model
      unrestrict_primary_key
      
      def homepage
        spec.to_json["homepage"]
      end
      
      def summary
        spec.to_json["summary"]
      end
      
      def social_media_url
        spec.to_json["social_media_url"]
      end
      
      def screenshots
        puts "ok"
          puts spec.to_json["screenshots"]
          spec.to_json["screenshots"]
      end
      
    end
  end
end
