ActiveSupport.on_load(:feature) do
  require 'subjects_engine/extension/feature_model'
  include SubjectsEngine::Extension::FeatureModel
end

ActiveSupport.on_load(:features_controller) do
  require 'subjects_engine/extension/feature_controller'
  include SubjectsEngine::Extension::FeatureController
  
end

ActiveSupport.on_load(:illustration) do
  require 'subjects_engine/extension/illustration_model'
  include SubjectsEngine::Extension::IllustrationModel
end