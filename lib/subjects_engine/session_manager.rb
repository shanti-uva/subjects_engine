module SubjectsEngine
  module SessionManager
    protected
    def current_perspective
      perspective_id = session[:perspective_id]
      begin
        if perspective_id.blank?
          @@current_perspective = Perspective.get_by_code('hum') if !defined?(@@current_perspect) || @@current_perspective.nil? || @@current_perspective.code != 'pol.admin.hier'
        else
          @@current_perspective = Perspective.find(perspective_id) if !defined?(@@current_perspect) || @@current_perspective.nil? || @@current_perspective.id != perspective_id
        end
      rescue ActiveRecord::RecordNotFound
        session[:perspective_id] = nil
        @@current_perspective = Perspective.get_by_code('hum')
      end
      return @@current_perspective
    end
    
    # Inclusion hook to make #current_perspective
    # available as ActionView helper method.
    def self.included(base)
      base.send :helper_method, :current_perspective
    end
  end
end