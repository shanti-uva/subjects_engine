ActiveSupport.on_load(:feature) do
  require_dependency 'subjects_engine/feature_extensions'
  include SubjectsEngine::FeatureExtensions
end

ActiveSupport.on_load(:features_controller) do
  require_dependency 'subjects_engine/feature_controller_extensions'
  include SubjectsEngine::FeatureControllerExtensions
  
end

ActiveSupport.on_load(:illustration) do
  require_dependency 'subjects_engine/illustration_extensions'
  include SubjectsEngine::IllustrationExtensions
end

ActiveSupport.on_load(:sessions_controller) do
  require_dependency 'subjects_engine/sessions_controller_extensions'
  include SubjectsEngine::SessionsControllerExtensions
end