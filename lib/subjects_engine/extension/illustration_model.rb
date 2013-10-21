module SubjectsEngine
  module Extension
    module IllustrationModel
      extend ActiveSupport::Concern
      
      included do
      end
      
      def place
        fid = self.picture.locations.first
        fid.nil? ? nil : PlacesIntegration::Feature.find(fid.to_i)
      end
      
      module ClassMethods
      end
    end
  end
end