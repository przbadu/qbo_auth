class AddCompanyIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :current_account_id, :integer
  end
end
