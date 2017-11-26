$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "subjects_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "subjects_engine"
  s.version     = SubjectsEngine::VERSION
  s.authors     = ["Andres Montano"]
  s.email       = ["amontano@virginia.edu"]
  s.homepage    = "http://subjects.kmaps.virginia.edu"
  s.summary     = "Engine that used by subjects app which contains the subject specific locales, controllers, models and views not found in kmaps engine."
  s.description = "Engine that used by subjects app which contains the subject specific locales, controllers, models and views not found in kmaps engine."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency 'rails', '>= 4.0'
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "pg"
end
