require 'rails_helper'

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"

  describe 'reply test' do
    before do
      @user = create(:michael)
      @followed_user = create(:lana)
      @unfollow_user = create(:archer)
      create(:one, :follower => @user, :followed => @followed_user)
      create(:three, :follower => @followed_user, :followed => @user)
      create(:four, :follower => @unfollow_user, :followed => @user)
      @followed_user.microposts.create!(content: "@#{@user.id}-michael-example Hello Michael")
      @unfollow_user.microposts.create!(content: "@#{@user.id}-michael-example Can you see me?")
      @followed_user_reply = @followed_user.microposts.where("in_reply_to = '@#{@user.id}-michael-example'")
      @unfollow_user_reply = @unfollow_user.microposts.where("in_reply_to = '@#{@user.id}-michael-example'")
    end

    context 'フォローしているユーザーからのリプライは見える' do
      it 'followed user check' do
        p @user.feed(@user)
        @followed_user_reply.each do |followed_user_reply|
          expect(@user.feed(@user).include?(followed_user_reply)).to be true
        end
      end
    end

    context 'フォローしていないユーザーからのリプライは見えない' do
      specify 'user can see reply from unfollow user' do
        @unfollow_user_reply.each do |unfollow_user_reply|
          expect(@user.feed(@user).include?(unfollow_user_reply)).to be true
        end
      end
    end

    context '他のユーザーからリプライは見えない' do
      specify 'other user cannot see reply' do
        @followed_user_reply.each do |other_user_reply|
          expect(@unfollow_user.feed(@unfollow_user).include?(other_user_reply)).to be false
        end
      end
    end

    context 'ユーザーを削除するとmessageも消える' do
      it
    end
  end
end
