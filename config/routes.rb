Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resource :quickbooks, only: [] do
    collection do
      get :oauth2
      get :callback
      get :disconnect
    end
  end

  resource :users, only: [] do
    collection do
      post :exchange_code_for_token
    end
  end
  resource :vendors, only: [:index]
end
