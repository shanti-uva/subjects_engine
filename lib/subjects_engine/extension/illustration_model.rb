module SubjectsEngine
  module Extension
    module IllustrationModel
      include ActionView::Helpers
      extend ActiveSupport::Concern
      
      included do
      end
      
      def place
        fid = self.picture.location
        fid.nil? ? nil : PlacesIntegration::Feature.find(fid)
      end
      
      def location
        pl = self.place
        return nil if pl.nil?
        perspectives = pl.perspectives
        per = perspectives.detect{|p| p.code=='pol.admin.hier'}
        ancestors = per.nil? ? perspectives.collect(&:ancestors).flatten.size : per.ancestors
        parent = ancestors.detect{|a| a.id != pl.id && a.feature_types.detect{|ft| ft.id=='29'}}
        parent = pl.parents.first if parent.nil?
      	str = pl.header
      	str << ", #{parent.header}" if !parent.nil?
        return link_to str, PlacesIntegration::Feature.element_url(pl.id, :format => 'html')
      end
      
      module ClassMethods
      end
    end
  end
end