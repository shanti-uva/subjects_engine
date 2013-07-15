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
      
      def kmaps_url
        "#{PlacesIntegration::PlacesResource.get_url}topics/#{self.fid}"
      end
      
      def feature_count
        Rails.cache.fetch("#{self.cache_key}/feature_count", :expires_in => 1.day) do
          PlacesIntegration::FeatureCategoryCount.find(:all, :params => {:category_id => self.fid}).first.count
        end
      end

      module ClassMethods
      end
    end
  end
end