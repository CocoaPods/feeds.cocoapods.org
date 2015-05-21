module FeedsApp
  module Models
    class Pod < Sequel::Model
      unrestrict_primary_key
      
      def json
        @json ||= JSON.parse(specification_data)
      end
      
      def homepage     
        json["homepage"]
      end
      
      def summary
        json["summary"]
      end
      
      def social_media_url
        json["social_media_url"]
      end
      
      def screenshots
        json["screenshots"]
      end
      
    end
  end
end
