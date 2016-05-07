# require 'config/environment'
require 'subjects_engine/import/feature_importation'

namespace :db do
  namespace :import do
    csv_desc = "Use to import CSV containing features into DB.\n" +
                  "Syntax: rake db:import:features SOURCE=csv-file-name TASK=task_code"
    desc csv_desc
    task :features => :environment do
      source = ENV['SOURCE']
      task = ENV['TASK']
      if source.blank? || task.blank?
        puts csv_desc
      else
        SubjectsEngine::FeatureImportation.new.do_feature_import(source, task)
      end
    end
  end
end