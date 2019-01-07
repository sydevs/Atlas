Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'application#index'
  get :manage, to: 'application#manage'

  resources :venues do
    resources :events, only: [:index, :new, :create]
    get :map, on: :collection
  end

  resources :events, only: [:index, :edit, :update, :destroy] do
    resources :registrations, only: [:index, :create, :update]
    get :map, on: :collection
  end
end
