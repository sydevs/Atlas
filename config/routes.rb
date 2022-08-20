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
        get :reminder
        get :status, on: :collection
        get :reminder, on: :collection
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
    #get :index, to: 'application#index'
    #get 'index/:api_key', to: 'application#index', as: :index_key

    get '(*path)', to: 'application#show'
    #get '/:api_key(/*path)', to: 'application#show', as: :key

    # For generating helpers
    get '/venue/:venue_id', to: 'application#show', as: :venue
    get '/:layer/:event_id', to: 'application#show', as: :event
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
      resources :audits, only: %i[index]
    end

    resources :regions, except: %i[index] do
      resources :managers, only: %i[index new create destroy]
      resources :events, only: %i[index]
      resources :areas, only: %i[index new create]
      resources :audits, only: %i[index]
    end

    resources :areas, except: %i[index] do
      get :geosearch, on: :collection
      get :geocode, on: :collection
      resources :managers, only: %i[index new create destroy]
      resources :events, only: %i[index new create]
      resources :audits, only: %i[index]
    end

    resources :venues, only: [] do
      get :geosearch, on: :collection
      get :geocode, on: :collection
    end

    resources :events do
      get :verify
      resources :pictures, only: %i[index create destroy]
      resources :managers, only: %i[index new create destroy]
      resources :registrations, only: %i[index]
      resources :audits, only: %i[index]
    end

    resources :managers do
      get :resend_verification
      get :activity
      get :search
      resources :managed_records, only: %i[index]
      resources :clients, only: %i[index]
      resources :events, only: %i[index]
      resources :audits, only: %i[index]
    end

    resources :managed_records, only: %i[index]

    resources :clients do
      resources :audits, only: %i[index]
    end

    resources :registrations, only: %i[index]
    resources :audits, only: %i[index]
  end

  namespace :api do
    get '404', to: 'api/application#error' # Not found
    get '429', to: 'api/application#error' # Too many requests
    get '500', to: 'api/application#error' # Internal server error

    post :graphql, to: "graphql#execute"
    get :graphql, to: "graphql#execute" if Rails.env.development?
  end
end
