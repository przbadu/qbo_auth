class QuickbooksController < ApplicationController
  skip_before_action :authenticate_user!

  def oauth2
    # prepare authorization request
    scopes = [
      IntuitOAuth::Scopes::ACCOUNTING,
      IntuitOAuth::Scopes::OPENID,
      IntuitOAuth::Scopes::EMAIL
    ]
    authorization_code_url = oauth_client.code.get_auth_uri(scopes)
    # redirect to Intuit's OAuth 2.0 server
    redirect_to authorization_code_url
  end

  def callback
    realm_id = params[:realmId]
    token = oauth_client.token.get_bearer_token(params[:code])
    # get user info
    user_info = oauth_client.openid.get_user_info(token.access_token)

    if email = user_info['email']
      user = User.find_or_create_me(email)
      account = user.qbo_accounts.create_from_oauth2(realm_id, token)
      user.current_account_id = account.id
      user.save(validate: false)

      # sign_in_and_redirect user
      token = user.create_new_auth_token
      code = JWT.encode token, CLIENT_CALLBACK_URL || ENV['CLIENT_CALLBACK_URL'], 'HS256'
      Rails.logger.info "Redirecting to #{CLIENT_CALLBACK_URL || ENV['CLIENT_CALLBACK_URL']}?code=#{code}"
      redirect_to "#{CLIENT_CALLBACK_URL || ENV['CLIENT_CALLBACK_URL']}?code=#{code}"
    else
      Rails.logger.info "Redirecting to #{CLIENT_CALLBACK_URL || ENV['CLIENT_CALLBACK_URL']}?code=#{code}"
      redirect_to "#{CLIENT_CALLBACK_URL || ENV['CLIENT_CALLBACK_URL']}?error=true"
    end
  end

  def disconnect
  end

  private

  def refresh_token_with(refresh_token)
    oauth_client.token.refresh_token(refresh_token)
  end
end
