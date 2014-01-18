module SubjectsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
      end
      
      def pid
        "S#{self.fid}"
      end

      def kmap_path(type = nil)
        a = ['topics', self.fid]
        a << type if !type.nil?
        a.join('/')
      end
      
      def kmaps_url
        "#{PlacesIntegration::PlacesResource.get_url}topics/#{self.fid}"
      end
      
      def feature_count
        Rails.cache.fetch("#{self.cache_key}/feature_count", :expires_in => 1.week) do
          PlacesIntegration::FeatureCategoryCount.find(:all, :params => {:category_id => self.fid}).first.count
        end
      end
      
      def media_count(options = {})
        media_count_hash = Rails.cache.fetch("#{self.cache_key}/media_count", :expires_in => 1.week) do
          media_place_count = MmsIntegration::MediaCategoryCount.find(:all, :params => {:category_id => self.fid}).dup
          media_count_hash = { 'Medium' => media_place_count.shift.count.to_i }
          media_place_count.each{|count| media_count_hash[count.medium_type] = count.count.to_i }
          media_count_hash
        end
        type = options[:type]
        return type.nil? ? media_count_hash['Medium'] : media_count_hash[type]
      end

      module ClassMethods
      end
    end
  end
end