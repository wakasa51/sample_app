class Micropost < ApplicationRecord
  belongs_to :user
  before_save { self.in_reply_to =  reply_user }
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size
  scope :including_replies, ->(user) { where("user_id = ? OR (user_id IN (SELECT followed_id FROM relationships WHERE follower_id = ?) AND in_reply_to = ?) OR in_reply_to LIKE ?", user.id, user.id, "", "%@#{user.id}\-#{user.name.sub(/\s/,'-').downcase}%" ) }

  private
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end

    def reply_user
      reply_user = ""
      if content.match?(/(@[^\s]+)\s.*/)
        reply_users = content.scan(/@\d+\-[^\s]+\s/).map do |reply_user|
          reply_user.gsub(" ", "")
        end
        if reply_users.length == 1
          reply_user = reply_users[0].downcase
        else
          reply_user = reply_users.join(", ").downcase
        end
      end
      return reply_user
    end
end
