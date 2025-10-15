module SubjectsEngine
  module FeatureExtensions
    extend ActiveSupport::Concern
    
    def pid
      "S#{self.fid}"
    end
    
    def feature_count
      Rails.cache.fetch("#{self.cache_key}/feature_count", :expires_in => 1.day) do
        PlacesIntegration::FeatureCategoryCount.find(:all, :params => {:category_id => self.fid}).first.count
      end
    end
    
    def media_count(**options)
      media_count_hash = Rails.cache.fetch("#{self.cache_key}/media_count", :expires_in => 1.day) do
        media_place_count = MmsIntegration::MediaCategoryCount.find(:all, :params => {:category_id => self.fid}).to_a
        if media_place_count.blank?
          media_count_hash = { 'Medium' => nil }
        else
          media_count_hash = { 'Medium' => media_place_count.shift.count.to_i }
        end
        media_place_count.each{|count| media_count_hash[count.medium_type] = count.count.to_i }
        media_count_hash
      end
      type = options[:type]
      return type.nil? ? media_count_hash['Medium'] : media_count_hash[type]
    end
    
    def calculate_prioritized_name(current_view)
      all_names = prioritized_names
      case current_view.code
      when 'roman.scholar'
        name = scholarly_prioritized_name(all_names)
      when 'pri.tib.sec.roman'
        name = tibetan_prioritized_name(all_names)
      when 'pri.tib.sec.chi'
        # If a writing system =tibt or writing system =Dzongkha name is available, show it
        name = tibetan_prioritized_name(all_names)
        name = KmapsEngine::FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id) if name.nil?
      when 'simp.chi'
        # If a writing system =hans name is available, show it
        name = KmapsEngine::FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id)
        name = KmapsEngine::FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hant').id) if name.nil?
      when 'trad.chi'
        # If a writing system=hant name is available, show it
        name = KmapsEngine::FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hant').id)
        name = KmapsEngine::FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('hans').id) if name.nil?
      when 'deva'
        # If a writing system =deva name is available, show it
        name = KmapsEngine::FeatureExtensionForNamePositioning::HelperMethods.find_name_for_writing_system(all_names, WritingSystem.get_by_code('deva').id)
      end
      name || popular_prioritized_name(all_names)
    end
    
    class_methods do
      def solr_url
        URI.join(SubjectsIntegration::Feature.get_url, "solr/")
      end
    end
  end
end
