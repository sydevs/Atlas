Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api/graphql"
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  passwordless_for :managers
  root to: 'info/application#index'

  namespace :info, path: '' do
    root to: 'application#index'
    get :about, to: 'application#about'
    get :statistics, to: 'application#statistics'
    get :privacy, to: 'application#privacy'
    get '(:locale)/privacy', to: 'application#privacy'
  end

  if Rails.env.development?
    namespace :mail do
      get :summary, to: 'application#summary'

      resources :managers, only: %i[] do
        get :welcome
        get :welcome, on: :collection
        get :verify
        get :verify, on: :collection
        get :login
        get :login, on: :collection
      end

      resources :events, only: %i[] do
        get :status
        get :registrations
        get :status, on: :collection
        get :registrations, on: :collection
      end

      resources :countries, :regions, :areas, only: %i[] do
        get :summary
        get :summary, on: :collection
      end

      resources :managed_records, only: %i[] do
        get :created
        get :created, on: :collection
        get 'created/:type', on: :collection, action: :created
      end
    end
  end

  namespace :map do
    root to: 'application#show'
    get :embed, to: 'application#embed', constraints: { format: 'js' }
    get '(*path)', to: 'application#show'
    # For generating helpers
    get '/event/:event_id', to: 'application#show', as: :event
    get '/country/:country_id', to: 'application#show', as: :country
    get '/region/:region_id', to: 'application#show', as: :region
    get '/area/:area_id', to: 'application#show', as: :area
    get '/venue/:venue_id', to: 'application#show', as: :venue

    # Redirect to new React atlas
    # get '/country/:country_id', :to => redirect { |params, request| "https://syatlas.pages.dev/countries/#{params[:country_id]}?#{request.params.slice(:key, :locale).to_query}" }
    # get '(*path)', :to => redirect { |params, request| "https://syatlas.pages.dev/#{params[:path]}?#{request.params.slice(:key, :locale).to_query}" }
  end

  namespace :cms do
    root to: 'application#dashboard'
    get :review, to: 'application#review'
    get :worldwide, to: 'application#show'
    get :help, to: 'application#help'

    resources :countries do
      resources :managers, only: %i[index new create destroy]
      resources :events, only: %i[index]
      resources :regions, only: %i[index new create]
      resources :areas, only: %i[index new create]
    end

    resources :regions, except: %i[index] do
      resources :managers, only: %i[index new create destroy]
      resources :events, only: %i[index]
      resources :areas, only: %i[index new create]
    end

    resources :areas, except: %i[index] do
      get :geosearch, on: :collection
      get :geocode, on: :collection
      resources :managers, only: %i[index new create destroy]
      resources :events, only: %i[index new create]
      resources :venues, only: %i[index]
    end

    resources :venues, only: %i[index] do
      get :geosearch, on: :collection
      get :geocode, on: :collection
    end

    resources :events do
      resources :pictures, only: %i[index create destroy]
      resources :managers, only: %i[index new create destroy]
      resources :registrations, only: %i[index]
      resources :audits, only: %i[index]
      resources :conversations, only: %i[index]
      get "/change/:effect", action: :change, as: :change, on: :member
    end

    resources :managers do
      get :resend_verification
      get :activity
      get :search
      resources :managed_records, only: %i[index]
      resources :clients, only: %i[index]
      resources :events, only: %i[index]
    end

    resources :managed_records, only: %i[index]

    resources :clients do
      # resources :audits, only: %i[index]
    end

    resources :registrations, only: %i[index show destroy] do
      resources :audits, only: %i[index]
      resources :conversations, only: %i[index]
    end
    
    resources :audits, only: %i[index show destroy]
    resources :conversations, only: %i[index show destroy]
  end

  namespace :api do
    get '404', to: 'api/application#error' # Not found
    get '429', to: 'api/application#error' # Too many requests
    get '500', to: 'api/application#error' # Internal server error

    post :graphql, to: "graphql#execute"
    get :graphql, to: "graphql#execute" if Rails.env.development?

    post :inbound, to: 'application#inbound_email'
    get :geojson, to: 'application#geojson'

    resources :areas, :regions, :venues, only: %i[show]
    resources :events, :countries, only: %i[index show] do
      resources :registrations, :regions, :venues, only: %i[create]
    end
  end

  # These routes should mirror the ones used in the React frontend
  resources :areas, :regions, :venues, only: %i[show]
  resources :events, :countries, only: %i[index show] do
    resources :registrations, :regions, :venues, only: %i[create]
  end
end
