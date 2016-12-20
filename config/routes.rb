Rails.application.routes.draw do
  
  get 'features/:id/places', to: 'places#show', as: 'feature_places'
  get 'features/:id/list_with_places', to: 'features#list_with_places'
  get 'features/:id/all_with_places', to: 'features#all_with_places'
  match 'features/fancy_nested_with_places', to: 'features#fancy_nested_with_places', via: [:post, :get]
  match 'features/:id/fancy_nested_with_places', to: 'features#fancy_nested_with_places', via: [:post, :get]
end