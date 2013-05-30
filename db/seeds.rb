# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

[ { :code => 'sci', :is_public => true, :name => 'Sciences' },
  { :code => 'hum', :is_public => true, :name => 'Humanities' },
  { :code => 'art', :is_public => true, :name => 'Arts' }
].each{|a| Perspective.update_or_create(a)}