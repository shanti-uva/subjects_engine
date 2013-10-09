module SubjectsEngine
  class Engine < ::Rails::Engine
    initializer :loader do |config|
      require 'subjects_engine/extension/feature_model'
      require 'subjects_engine/extension/feature_controller'
      require 'subjects_engine/extension/illustration_model'
      require 'subjects_engine/session_manager'
      
      ApplicationController.send :include, SubjectsEngine::SessionManager
      Feature.send :include, SubjectsEngine::Extension::FeatureModel
      FeaturesController.send :include, SubjectsEngine::Extension::FeatureController
      Illustration.send :include, SubjectsEngine::Extension::IllustrationModel
    end
  end
end
