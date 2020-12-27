# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :registerable, :rememberable
  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable

  # note that this include statement comes AFTER the devise block above
  include DeviseTokenAuth::Concerns::User

  # associations
  has_many :activities
  has_many :qbo_accounts
  belongs_to :current_account, foreign_key: :current_account_id, class_name: 'QboAccount', optional: true

  def self.find_or_create_me(email)
    User.where(email: email).first_or_initialize.tap do |user|
      user.password = Devise.friendly_token
      user.save!(validate: false)
    end
  end
end
