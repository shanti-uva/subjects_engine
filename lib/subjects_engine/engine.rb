module SubjectsEngine
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile.concat(['subjects_engine/related.css','subjects_engine/related-section-initializer.js'])
    end
    
    config.to_prepare do
      # Extending / overriding kmaps_engine controllers
      require_dependency 'features_controller'
      require_dependency 'subjects_engine/feature_controller_extensions'
      FeaturesController.include SubjectsEngine::FeatureControllerExtensions
      
      require_dependency 'sessions_controller'
      require_dependency 'subjects_engine/sessions_controller_extensions'
      SessionsController.include SubjectsEngine::SessionsControllerExtensions
      
      # Extending / overriding kmaps_engine models
      require_dependency 'feature'
      require_dependency 'subjects_engine/feature_extensions'
      Feature.include SubjectsEngine::FeatureExtensions
      
      require_dependency 'illustration'
      require_dependency 'subjects_engine/illustration_extensions'
      Illustration.include SubjectsEngine::IllustrationExtensions
    end
  end
end
