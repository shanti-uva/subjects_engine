name = feature.prioritized_name(@view)
# The following is performed because the name expression returns nil for Feature.find(15512)
header = name.nil? ? feature.pid : name.name
children = feature.current_children(@perspective, @view).reject{ |f| f.feature_count.to_i <= 0 }.sort_by do |f|
  name = f.prioritized_name(@view)
  [f.position, name.nil? ? f.pid : name.name]
end
caption = feature.caption
options = { key: feature.fid, title: header }
options[:caption] = caption.content if !caption.nil?
xml.feature(options) do
  xml.children(type: 'array') do
    xml << render(partial: 'fancy_nested_feature_with_places', formats: [:xml], collection: children, as: :feature) if !children.empty?
  end
end