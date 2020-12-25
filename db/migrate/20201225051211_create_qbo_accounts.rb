class CreateQboAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :qbo_accounts do |t|
      t.string :token_type
      t.integer :expires_in
      t.string :refresh_token
      t.integer :x_refresh_token_expires_in
      t.string :access_token
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
