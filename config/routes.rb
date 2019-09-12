Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  passwordless_for :managers

  root to: 'application#map'
  get :map, to: 'application#map'
  get :dashboard, to: 'application#dashboard'
  get :statistics, to: 'application#statistics'

  resources :managers
  resources :regions

  resources :venues do
    resources :events, only: %i[new create]
  end

  resources :events, only: %i[show edit update destroy] do
    resources :registrations, only: %i[index]
  end

  resource :registrations, only: %i[create update]
end
