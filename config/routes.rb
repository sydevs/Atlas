Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'application#index'
  get :manage, to: 'application#manage'
  get :map, to: 'application#map'

  resources :venues do
    resources :events, only: %i[index new create]
  end

  resources :events, only: %i[show index edit update destroy] do
    resources :registrations, only: %i[index]
  end

  resource :registrations, only: %i[create update]
end
