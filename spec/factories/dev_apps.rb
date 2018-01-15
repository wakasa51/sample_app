FactoryBot.define do
  factory :dev_app do
    factory :twtr do
      app_name "twtr"
      association :user, factory: :michael
      contact_mail "twtr@contact.com"
      consumer_id "twtrtanoshi"
      consumer_secret "tanoshitwtr"
      callback_url "twtr.co.jp"
    end

    factory :ggle do
      app_name "ggle"
      association :user, factory: :archer
      contact_mail "ggle@gglemail.ggle"
      consumer_id "gglekasu"
      consumer_secret "kasuggle"
      callback_url "ggle.com"
    end
  end
end
