Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'application#map'
  get :map, to: 'application#map'
  get :dashboard, to: 'application#dashboard'
  get :statistics, to: 'application#statistics'

  resources :venues do
    resources :events, only: %i[index new create]
  end

  resources :events, only: %i[show index edit update destroy] do
    post :images, to: 'events#upload_image', as: :upload_image
    delete 'images/:index', to: 'events#destroy_image', as: :destroy_image
    resources :registrations, only: %i[index]
  end

  resource :registrations, only: %i[create update]
end
