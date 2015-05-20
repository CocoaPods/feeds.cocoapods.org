module FeedsApp
  module Models
    class Pod < Sequel::Model
      unrestrict_primary_key
      
      def homepage     
        JSON.parse(spec)["homepage"]
      end
      
      def summary
        JSON.parse(spec)["summary"]
      end
      
      def social_media_url
        JSON.parse(spec)["social_media_url"]
      end
      
      def screenshots
        JSON.parse(spec)["screenshots"]
      end
      
    end
  end
end
