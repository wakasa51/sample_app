json.user do
  json.extract! @user, :id, :name, :email, :created_at, :updated_at
  json.following do
    json.array!(@users) do |user|
      json.extract! user, :id, :name, :email, :created_at, :updated_at
    end
  end
end
