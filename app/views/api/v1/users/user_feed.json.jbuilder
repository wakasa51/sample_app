json.user do
  json.extract! @user, :id, :name, :email, :created_at, :updated_at
  json.microposts do
    json.array!(@feed_items) do |micropost|
      json.extract! micropost, :id, :content, :user_id, :created_at, :updated_at, :in_reply_to
    end
  end
end
