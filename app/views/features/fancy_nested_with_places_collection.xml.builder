xml.instruct!
xml.features(type: 'array') do
  xml << render(partial: 'fancy_nested_feature_with_places', format: 'xml', collection: @features, as: :feature) if !@features.empty?
end