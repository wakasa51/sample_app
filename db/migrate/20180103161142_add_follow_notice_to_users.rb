class AddFollowNoticeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :follow_notice, :integer, default: 1, null: false
  end
end
