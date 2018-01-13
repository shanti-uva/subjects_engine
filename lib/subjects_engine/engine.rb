module SubjectsEngine
  class Engine < ::Rails::Engine
    initializer :loader do |config|
      require 'subjects_engine/extension/feature_model'
      require 'subjects_engine/extension/feature_controller'
      require 'subjects_engine/extension/illustration_model'

      Feature.send :include, SubjectsEngine::Extension::FeatureModel
      FeaturesController.send :include, SubjectsEngine::Extension::FeatureController
      Illustration.send :include, SubjectsEngine::Extension::IllustrationModel
    end
  end
end
