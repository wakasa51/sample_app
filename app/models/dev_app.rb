class DevApp < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :app_name, presence: true, length: { maximum: 100 }
  VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :contact_mail, presence:true, length: { maximum: 250 }, format: { with: VALID_EMAIL_REGEX }
  validates :consumer_id, presence: true, length: { maximum: 50 }
  validates :consumer_secret, presence: true, length: { maximum: 100 }
  validates :callback_url, presence: true, length: { maximum: 350 }

  
end
