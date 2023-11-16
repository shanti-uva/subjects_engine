xml.instruct!
xml.features(type: 'array') do
  xml << render(partial: 'fancy_nested_feature_with_places', format: 'xml', locals: {feature: @feature})
end