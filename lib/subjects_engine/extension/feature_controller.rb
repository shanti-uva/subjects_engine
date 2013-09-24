module SubjectsEngine
  module Extension
    module FeatureController
      extend ActiveSupport::Concern

      included do
      end
      
      def related_list
        @feature = Feature.find(params[:id])
        @feature_relation_type = FeatureRelationType.find(params[:feature_relation_type_id])
        @feature_is_parent = params[:feature_is_parent].to_i
        if @feature_is_parent==0
          @relations = FeatureRelation.where(:feature_relation_type_id => @feature_relation_type.id, :child_node_id => @feature.id, 'cached_feature_names.view_id' => current_view.id).joins(:parent_node => {:cached_feature_names => :feature_name}).order('feature_names.name')
        else
          @relations = FeatureRelation.where(:feature_relation_type_id => @feature_relation_type.id, :parent_node_id => @feature.id, 'cached_feature_names.view_id' => current_view.id).joins(:child_node => {:cached_feature_names => :feature_name}).order('feature_names.name')
        end
        @total_relations_count = @relations.length
        @relations = @relations.paginate(:page => params[:page] || 1, :per_page => 8)
        @params = params
        # render related_list.js.erb
      end
      
      def list_with_places
        feature = Feature.get_by_fid(params[:id])
        @features = feature.descendants.reject{|f| f.feature_count.to_i <= 0 }
        @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
        @view ||= View.get_by_code('roman.popular')
        respond_to do |format|
          format.xml  { render 'list' }
          format.json { render :json => Hash.from_xml(render_to_string(:action => 'list.xml.builder')) }
        end
      end
      
      def all_with_places
        @feature = Feature.get_by_fid(params[:id])
        @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
        @view ||= View.get_by_code('roman.popular')
        respond_to do |format|
          format.xml
          format.json { render :json => Hash.from_xml(render_to_string(:action => 'all_with_places.xml.builder')) }
        end
      end
    end
  end
end