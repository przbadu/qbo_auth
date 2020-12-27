class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'citext'

    create_table :activities do |t|
      t.integer :action
      t.string :entity_name
      t.string :third_party_ids, array: true, default: []
      t.jsonb :logs, null: false, default: {}
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :qbo_account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
