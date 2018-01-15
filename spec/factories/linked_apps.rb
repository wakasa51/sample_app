FactoryBot.define do
  factory :linked_app do
    factory :saisyo do
      association :user, factory: :michael
      association :dev_app, factory: :ggle
    end

    factory :tsugi do
      association :user, factory: :lana
      association :dev_app, factory: :twtr
    end
  end
end
