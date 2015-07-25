module SubjectsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
      end
      
      def pid
        "S#{self.fid}"
      end
      
      def feature_count
        Rails.cache.fetch("#{self.cache_key}/feature_count", :expires_in => 1.day) do
          PlacesIntegration::FeatureCategoryCount.find(:all, :params => {:category_id => self.fid}).first.count
        end
      end
      
      def media_count(options = {})
        media_count_hash = Rails.cache.fetch("#{self.cache_key}/media_count", :expires_in => 1.day) do
          media_place_count = MmsIntegration::MediaCategoryCount.find(:all, :params => {:category_id => self.fid}).to_a
          media_count_hash = { 'Medium' => media_place_count.shift.count.to_i }
          media_place_count.each{|count| media_count_hash[count.medium_type] = count.count.to_i }
          media_count_hash
        end
        type = options[:type]
        return type.nil? ? media_count_hash['Medium'] : media_count_hash[type]
      end

      def solr_id
        "subjects-#{self.fid}"
      end
      
      def document_for_rsolr
        doc = RSolr::Xml::Document.new
        doc.add_field('tree', 'subjects')
        per = Perspective.get_by_code('gen')
        hierarchy = self.closest_ancestors_by_perspective(per)
        hierarchy.each{ |f| doc.add_field('ancestors_default', f.prioritized_name(View.get_by_code('roman.popular'))) }
        hierarchy.each{ |f| doc.add_field('ancestor_ids_default', f.fid) }
        doc
      end

      module ClassMethods
      end
    end
  end
end