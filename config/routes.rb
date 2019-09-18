Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  passwordless_for :managers
  mount SubdivisionSelect::Engine, at: 'subdivisions'
  
  root to: 'application#map'
  get :map, to: 'application#map'
  get :dashboard, to: 'application#dashboard'
  get :statistics, to: 'application#statistics'

  resources :managers

  # ===== VENUES AND EVENTS ===== #
  resources :venues do
    resources :events, only: %i[new create]
  end

  resources :events, only: %i[show edit update destroy] do
    resources :registrations, only: %i[index]
  end

  resource :registrations, only: %i[create update]

  # ===== REGIONS ===== #
  namespace :regions, path: '' do
    resources :countries, only: %i[index show new create edit destroy] do
      resources :provinces, only: %i[new create]
      resources :local_areas, only: %i[new create]
    end

    resources :provinces, only: %i[show edit destroy] do
      resources :local_areas, only: %i[new create]
    end

    resources :local_areas, only: %i[show edit update destroy]
  end
end
