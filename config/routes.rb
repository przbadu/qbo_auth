Rails.application.routes.draw do
  get 'quickbooks/oauth2'
  get 'quickbooks/callback'
  get 'quickbooks/disconnect'
  mount_devise_token_auth_for 'User', at: 'auth'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
