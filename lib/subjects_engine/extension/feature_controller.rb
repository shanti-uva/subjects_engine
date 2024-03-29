module SubjectsEngine
  module Extension
    module FeatureController
      extend ActiveSupport::Concern

      included do
      end
      
      def search
        conditions = {:is_public => 1}
        search = Search.new(params[:search])
        @features = nil
        # The search params that should be observed when creating the session store of search params
        valid_search_keys = [ :page ]
        fid = search.fid
        #search_scope = params[:search_scope].blank? ? 'global' : params[:search_scope]
        #if !search_scope.blank?
        #  case search_scope
        #  when 'fid'
        #    feature = Feature.find_by(is_public: 1, fid: params[:filter].gsub(/[^\d]/, '').to_i)
        #    if !feature.id.nil?
        #      render :url => {:action => 'expand_and_show',  :id => '59' }, :layout => false
        #    else
        #    end
        #  when 'contextual'
        #    if params[:context_id].blank?
        #      perform_global_search(options, search_options)
        #    else
        #      perform_contextual_search(options, search_options)
        #    end
        #  when 'name'
        #    @features = Feature.name_search(params[:filter])
        #  else
          if !fid.blank?
            @features = Feature.where(:is_public => 1, :fid => fid.gsub(/[^\d]/, '').to_i).page(1)
          else
            joins = []
            @features = perform_global_search(search).where(conditions).paginate(:page => params[:page] || 1, :per_page => 10)
            @features = @features.joins(joins.join(' ')).select('features.*, DISTINCT feature.id') unless joins.empty?
          end
        #end
        # When using the session store features, we need to provide will_paginate with info about how to render
        # the pagination, so we'll store it in session[:search], along with the feature ids 
        session[:search] = { :params => params.reject{|key, val| !valid_search_keys.include?(key.to_sym)}.merge(search.to_h),
          :page => params[:page] ||= 1, :per_page => @features.per_page, :total_entries => @features.total_entries,
          :total_pages => @features.total_pages, :feature_ids => @features.collect(&:id) }
        # Set the current menu_item to 'results', so that the Results will stay open when the user browses
        # to a new page
        session[:interface] ||= {}
        session[:interface][:menu_item] = 'results'
        respond_to do |format|
          format.js # search.js.erb
          format.html { render :partial => 'search_results', :locals => {:features => @features} }
        end
      end
      
      def api_format_feature(feature)
        f = {}
        f[:id] = feature.id
        f[:name] = feature.name
        f[:descriptions] = feature.descriptions.collect{|d| {
          :id => d.id,
          :is_primary => d.is_primary,
          :title => d.title,
          :content => d.content,
        }}
        f[:has_shapes] = feature.shapes.empty? ? 0 : 1
        #f[:parents] = feature.parents.collect{|p| api_format_feature(p) }
        f
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
        # render related_list.js.erb
      end
      
      def list_with_places
        feature = Feature.get_by_fid(params[:id])
        @features = feature.descendants.reject{|f| f.feature_count.to_i <= 0 }
        @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
        @view ||= View.get_by_code(default_view_code)
        respond_to do |format|
          format.xml  { render 'list' }
          format.json { render json: Hash.from_xml(render_to_string(action: 'list', format: 'xml')) }
        end
      end
      
      def all_with_places
        @feature = Feature.get_by_fid(params[:id])
        @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
        @view ||= View.get_by_code(default_view_code)
        respond_to do |format|
          format.xml
          format.json { render json: Hash.from_xml(render_to_string(action: 'all_with_places', format: 'xml')) }
        end
      end
      
      def fancy_nested_with_places
        params_id = params[:id]
        @view = params[:view_code].nil? ? nil : View.get_by_code(params[:view_code])
        @view ||= View.get_by_code(default_view_code)
        @perspective = params[:perspective_code].nil? ? nil : Perspective.get_by_code(params[:perspective_code])
        @perspective ||= Perspective.get_by_code(default_perspective_code)
        if params_id.nil?
          @features = Feature.current_roots(@perspective, @view).reject{ |f| f.feature_count.to_i <= 0 }.sort_by{ |f| [f.position, f.prioritized_name(@view).name] }.reject{ |f| f.feature_count.to_i <= 0 }
        else
          @feature = Feature.get_by_fid(params_id)
        end
        respond_to do |format|
          format.xml { render 'fancy_nested_with_places_collection' if params_id.nil? }
          format.json do
            hash = Hash.from_xml(render_to_string(action: params_id.nil? ? 'fancy_nested_with_places_collection' : 'fancy_nested_with_places', format: 'xml'))
            render json: hash['features']
          end
        end
      end
    end
  end
end
