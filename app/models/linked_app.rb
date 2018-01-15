class LinkedApp < ApplicationRecord
  belongs_to :user
  belongs_to :dev_app
  validates :user_id, presence: true
  validates :dev_app_id, presence: true
  # validates :access_token, length: { maximum: 100 }
end
