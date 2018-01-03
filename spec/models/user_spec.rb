require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'reply test' do
    let(:user){ create(:michael) }
    let(:followed_user){ create(:lana) }
    let(:unfollow_user){ create(:archer) }
    let(:followed_user_reply){ followed_user.microposts.create!(content: "@#{user.id}-michael-example Hello Michael") }
    let(:unfollow_user_reply){ unfollow_user.microposts.create!(content: "@#{user.id}-michael-example Can you see me?") }
    let(:other_user_reply){ followed_user_reply }

    before do
      create(:one, :follower => user, :followed => followed_user)
      create(:three, :follower => followed_user, :followed => user)
      create(:four, :follower => unfollow_user, :followed => user)
    end

    context 'フォローしているユーザーからのリプライは見える' do
      it 'user can see reply from followed user' do
        expect(user.feed(user).include?(followed_user_reply)).to be true
      end
    end

    context 'フォローしていないユーザーからのリプライも見える' do
      specify 'user can see reply from unfollow user' do
        expect(user.feed(user).include?(unfollow_user_reply)).to be true
      end
    end

    context '他のユーザーからリプライは見えない' do
      specify 'other user cannot see reply' do
        expect(unfollow_user.feed(unfollow_user).include?(other_user_reply)).to be false
      end
    end

    context 'ユーザーを削除するとmessageも消える' do
      specify 'when deleting user, message also deleted' do
        user.send_messages.create!(content: "hello", to_user_id: followed_user.id)
        expect { user.destroy }.to change { Message.count }.by(-1)
      end
    end
  end
end
