FactoryBot.define do
  factory :message do
    factory :air do
      content "There is an air plane"
      created_at 30.minutes.ago
    end

    factory :bus do
      content "There are busses"
      created_at 2.hours.ago
    end

    factory :car do
      content "I hava two cars"
      created_at 3.days.ago
    end

    factory :most_recent_message do
      content "I drive my car"
      created_at Time.zone.now
    end
  end
end
