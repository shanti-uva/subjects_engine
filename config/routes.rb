Rails.application.routes.draw do
  get 'features/:id/list_with_places', to: 'features#list_with_places'
  get 'features/:id/all_with_places', to: 'features#all_with_places'
end