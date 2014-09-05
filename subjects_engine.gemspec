$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "subjects_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "subjects_engine"
  s.version     = SubjectsEngine::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SubjectsEngine."
  s.description = "TODO: Description of SubjectsEngine."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.8"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "pg"
end
