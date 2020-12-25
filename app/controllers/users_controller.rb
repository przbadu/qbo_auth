class UsersController < ApplicationController
  skip_before_action :authenticate_user!

  def exchange_code_for_token
    code = params['code']
    token = Aes256Encrypter.decode(code)
    render json: JSON.parse(token)
  end
end
