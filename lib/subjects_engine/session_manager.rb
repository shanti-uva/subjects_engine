module SubjectsEngine
  module SessionManager
    protected
    def default_perspective_code
      'hum'
    end
    
    # Inclusion hook to make #current_perspective
    # available as ActionView helper method.
    def self.included(base)
      base.send :helper_method, :default_perspective_code
    end
  end
end