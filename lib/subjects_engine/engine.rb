module SubjectsEngine
  class Engine < ::Rails::Engine
    initializer :loader do |config|
      require 'subjects_engine/extension/feature_model'
      require 'subjects_engine/session_manager'
      
      Feature.send :include, SubjectsEngine::Extension::FeatureModel
      ApplicationController.send :include, SubjectsEngine::SessionManager
    end
  end
end
