Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  passwordless_for :managers
  mount SubdivisionSelect::Engine, at: 'subdivisions'
  
  root to: 'application#about'
  get :map, to: 'application#map'
  get :about, to: 'application#about'
  get :statistics, to: 'application#statistics'

  namespace :cms do
    root to: 'application#show'
    get :regions, to: 'application#regions'

    resources :countries, except: %i[edit update] do
      get :regions
      resources :managers, only: %i[index new create destroy]
      resources :venues, only: %i[index]
      resources :events, only: %i[index]
      resources :provinces, only: %i[new create]
      resources :local_areas, only: %i[new create]
    end

    resources :provinces, except: %i[edit update index] do
      get :regions
      resources :managers, only: %i[index new create destroy]
      resources :venues, only: %i[index new create]
      resources :events, only: %i[index]
      resources :local_areas, only: %i[new create]
    end

    resources :local_areas, except: %i[index] do
      resources :managers, only: %i[index new create destroy]
      resources :venues, only: %i[index new create]
      resources :events, only: %i[index]
    end

    resources :venues do
      resources :managers, only: %i[index new create destroy]
      resources :events, only: %i[index new create]
    end

    resources :events do
      get :regions
      resources :managers, only: %i[index new create destroy]
      resources :registrations, only: %i[index]
    end

    resources :managers do
      get :regions
      resources :venues, only: %i[index]
      resources :events, only: %i[index]
    end

    resources :registrations, only: %i[index]
  end

=begin
  # ===== VENUES AND EVENTS ===== #
  resources :venues do
    resources :events, only: %i[new create]
  end

  resources :events, only: %i[show index edit update destroy] do
    post :images, to: 'events#upload_image', as: :upload_image
    delete 'images/:index', to: 'events#destroy_image', as: :destroy_image
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

    resources :local_areas
  end
=end
end
