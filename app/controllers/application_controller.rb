class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!, except: :home
  before_action :refresh_token!

  def current_account
    @current_account ||= current_user.current_account if current_user
  end

  def qbo_api
    @qbo_api ||= QboApi.new(access_token: current_account.access_token, realm_id: current_account.realm_id)
  end

  def refresh_token!
    return unless current_account

    if current_account.token_expired?
      new_token = oauth_client.token.refresh_tokens(current_account.refresh_token)
      current_account.update_token!(new_token)
    end
  end

  def oauth_client
    IntuitOAuth::Client.new(
      ENV['QBO_CLIENT_ID'],
      ENV['QBO_CLIENT_SECRET'],
      "#{root_url}quickbooks/callback",
      ENV['QBO_PRODUCTION_MODE'].to_s == 'true' ? 'production' : 'development'
    )
  end
end
