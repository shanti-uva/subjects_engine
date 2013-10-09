module SubjectsEngine
  module Extension
    module IllustrationModel
      extend ActiveSupport::Concern
      
      included do
      end
      
      def location
        fid = self.picture.location
        fid.nil? ? nil : PlacesIntegration::Feature.find(fid)
      end
      
      module ClassMethods
      end
    end
  end
end