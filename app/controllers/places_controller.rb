class PlacesController < ApplicationController
  allow_unauthenticated_access
  
  def show
    @feature = Feature.get_by_fid(params[:id])
    @places = PlacesIntegration::Topic.paginated_features(@feature.fid, page: params[:page], :per_page => params[:per_page])
    respond_to do |format|
      format.js
      format.html
    end
  end
end
