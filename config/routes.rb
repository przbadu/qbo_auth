Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  root 'quickbooks#oauth2'
  resource :quickbooks, only: [] do
    collection do
      get :oauth2
      get :callback
      get :disconnect
    end
  end

  resources :users, only: [] do
    collection do
      post :exchange_code_for_token
    end
  end
  resources :vendors, only: :index
  resources :customers, only: [:index] do
    collection do
      get :with_logs
      post :mark_inactive
      post :export
    end
  end

  # Action cable
  mount ActionCable.server => '/cable'
  # sidekiq
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
