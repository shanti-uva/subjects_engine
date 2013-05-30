module SubjectsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
      end

      def kmap_path(type = nil)
        a = ['places', self.fid]
        a << type if !type.nil?
        a.join('/')
      end

      module ClassMethods
      end
    end
  end
end