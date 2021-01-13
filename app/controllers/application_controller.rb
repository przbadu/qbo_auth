class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!, except: :home
  before_action :refresh_token!

  def home
    render json: {
      message: 'working!',
      server_URL: ENV['QBO_REDIRECT_URL'],
      client_url: ENV['CLIENT_CALLBACK_URL']
    }
  end

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
    Rails.logger.warn "URL2::::::::::::#{ENV['QBO_REDIRECT_URL'] || root_url}quickbooks/callback"

    if Rails.env.production?
      @redirect_url = 'https://qboapi.tk/quickbooks/callback'
    else
      @redirect_url = "#{ENV['QBO_REDIRECT_URL'] || root_url}quickbooks/callback"
    end

    IntuitOAuth::Client.new(
      ENV['QBO_CLIENT_ID'],
      ENV['QBO_CLIENT_SECRET'],
      @redirect_url,
      ENV['QBO_PRODUCTION_MODE'].to_s == 'true' ? 'production' : 'development'
    )
  end
end
