User.create!(name: "Example User", email: "example@railstutorial.org", password: "foobar", password_confirmation: "foobar", admin:true, activated: true, activated_at: Time.zone.now)

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n + 1}@railstutorial.org"
  password = "password"
  User.create!(name: name, email: email, password: password, password_confirmation: password, activated: true, activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  reply = ""
  users.each { |user| user.microposts.create!(content: content, in_reply_to: reply)}
end
User.second.microposts.create!(content: "@1-example-user hello example")
User.second.microposts.create!(content: "@1-example-user @6-Miss-Tre-Denesik hello example and denesik")

# リレーションシップ
users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

User.second.send_messages.create!(content: "Hello Michael", to_user_id: User.first.id, created_at: 10.minutes.ago)
User.first.send_messages.create!(content: "Hey Archer. How are you?", to_user_id: User.second.id)
User.third.send_messages.create!(content: "Hi Michael", to_user_id: User.first.id)
