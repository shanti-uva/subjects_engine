Rails.application.routes.draw do
  match 'features/:id/list_with_places' => 'features#list_with_places'
  match 'features/:id/all_with_places' => 'features#all_with_places'
end