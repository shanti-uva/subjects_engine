# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

[ { :code => 'gen', :is_public => true, :name => 'General' }
].each{|a| Perspective.update_or_create(a)}