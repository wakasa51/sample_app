class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.text :content
      t.integer :from_user_id
      t.integer :to_user_id

      t.timestamps
    end
    add_index :messages, [:from_user_id, :created_at]
  end
end
