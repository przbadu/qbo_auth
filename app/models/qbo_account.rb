class QboAccount < ApplicationRecord
  # associations
  has_many :activities
  belongs_to :user

  def self.create_from_oauth2(realm_id, token)
    QboAccount.where(realm_id: realm_id).first_or_initialize.tap do |acc|
      acc.update_token!(token)
    end
  end

  def update_token!(token)
    self.expires_in = token.expires_in.seconds.from_now
    self.refresh_token = token.refresh_token
    self.access_token = token.access_token
    self.x_refresh_token_expires_in = token.x_refresh_token_expires_in.seconds.from_now
    self.save!
  end

  def token_expired?
    self.expires_in <= Time.now.utc
  end

  def x_token_expired?
    self.x_refresh_token_expires_in <= Time.now.utc
  end
end
