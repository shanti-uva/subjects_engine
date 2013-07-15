module SubjectsEngine
  class Engine < ::Rails::Engine
    initializer :loader do |config|
      require 'subjects_engine/extension/feature_model'
      require 'subjects_engine/extension/feature_controller'
      require 'subjects_engine/session_manager'
      
      Feature.send :include, SubjectsEngine::Extension::FeatureModel
      FeaturesController.send :include, SubjectsEngine::Extension::FeatureController
      ApplicationController.send :include, SubjectsEngine::SessionManager
    end
  end
end
