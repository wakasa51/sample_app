class CreateLinkedApps < ActiveRecord::Migration[5.1]
  def change
    create_table :linked_apps do |t|
      t.references :user, foreign_key: true
      t.references :dev_app, foreign_key: true
      t.string :access_token

      t.timestamps
    end
    add_index :linked_apps, [:user_id, :dev_app_id], unique: true
  end
end
