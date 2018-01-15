class CreateDevApps < ActiveRecord::Migration[5.1]
  def change
    create_table :dev_apps do |t|
      t.string :app_name
      t.references :user, foreign_key: true
      t.string :contact_mail
      t.string :consumer_id, null:false
      t.string :consumer_secret, null:false
      t.string :callback_url, null:false

      t.timestamps
    end
  end
end
