# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

[ { :code => 'gen', :is_public => true, :name => 'General' }
].each{|a| Perspective.update_or_create(a)}

[ { is_symmetric: true,  label: 'is in conflict with',     asymmetric_label: 'is in conflict with',    code: 'is.in.conflict.with',    is_hierarchical:  false},
  { is_symmetric: true,  label: 'is affiliated with',      asymmetric_label: 'is affiliated with',     code: 'is.affiliated.with',     is_hierarchical: false},
  { is_symmetric: false, label: 'is mother of',            asymmetric_label: 'is child of',            code: 'is.child.of',            is_hierarchical: false, asymmetric_code: 'is.mother.of'},
  { is_symmetric: false, label: 'has as an instantiation', asymmetric_label: 'is an instantiation of', code: 'is.an.instantiation.of', is_hierarchical: false, asymmetric_code: 'has.as.an.instantiation'},
  { is_symmetric: false, label: 'has as a part',           asymmetric_label: 'is part of',             code: 'is.part.of',             is_hierarchical: true,  asymmetric_code: 'has.as.a.part'}
].each{|a| FeatureRelationType.update_or_create(a)}
