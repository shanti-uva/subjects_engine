module SubjectsEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
        acts_as_indexable uid_prefix: 'subjects'
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

      def document_for_rsolr
        per = Perspective.get_by_code('gen')
        v = View.get_by_code('roman.popular')

        hierarchy = self.closest_ancestors_by_perspective(per)
        doc = { tree: 'subjects',
          ancestors_default: hierarchy.collect{ |f| f.prioritized_name(View.get_by_code('roman.popular')).name },
          ancestor_ids_default: hierarchy.collect(&:fid),
          block_type: ['parent'],
          '_childDocuments_'  =>  self.parent_relations.collect do |pr|
            { id: "#{self.uid}_#{pr.feature_relation_type.code}_#{pr.parent_node.fid}",
              block_child_type: ["related_subjects"],
              related_subjects_id_s: pr.parent_node.fid,
              related_subjects_header_s:  pr.parent_node.prioritized_name(v).name,
              related_subjects_path_s: pr.parent_node.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
              related_subjects_relation_label_s: pr.feature_relation_type.asymmetric_label,
              related_subjects_relation_code_s: pr.feature_relation_type.code,
              related_kmaps_node_type: 'parent',
              block_type: ['child'] }
          end + self.child_relations.collect do |pr|
            { id: "#{self.uid}_#{pr.feature_relation_type.asymmetric_code}_#{pr.child_node.fid}",
              block_child_type: ["related_subjects"],
              related_subjects_id_s: pr.child_node.fid,
              related_subjects_header_s: pr.child_node.prioritized_name(v).name,
              related_subjects_path_s: pr.child_node.closest_ancestors_by_perspective(per).collect(&:fid).join('/'),
              related_subjects_relation_label_s: pr.feature_relation_type.label,
              related_subjects_relation_code_s: pr.feature_relation_type.asymmetric_code,
              related_kmaps_node_type: 'child',
              block_type: ['child'] }
          end }
        doc
      end

      module ClassMethods
      end
    end
  end
end
