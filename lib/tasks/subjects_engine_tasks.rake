# desc "Explaining what the task does"
namespace :subjects_engine do
  namespace :db do
    desc "Load seeds for kmaps engine tables"
    task :seed => :environment do
      SubjectsEngine::Engine.load_seed
    end
  end
end