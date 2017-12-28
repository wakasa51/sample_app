class AddInReplyToToMicropost < ActiveRecord::Migration[5.1]
  def change
    add_column :microposts, :in_reply_to, :string, default: "", null: false
  end
end
