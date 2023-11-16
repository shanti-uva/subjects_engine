module SubjectsEngine
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile.concat(['subjects_engine/related.css','subjects_engine/related-section-initializer.js'])
    end
  end
end
