require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:user) { create(:michael)}
  let(:other_user) { create(:archer)}
  let(:message) { Message.new(content: "hello", from_user_id: other_user.id, to_user_id: user.id, created_at:10.minutes.ago)}
  let(:most_recent_message) { create(:most_recent_message, from_user_id: other_user.id, to_user_id: user.id) }

  it "should be valid" do
    expect(message).to be_valid
  end

  it "should require a content" do
    message.content = nil
    expect(message).to be_invalid
  end

  it "should require a from_user_id" do
    message.from_user_id = nil
    expect(message).to be_invalid
  end

  it "should require a to_user_id" do
    message.to_user_id = nil
    expect(message).to be_invalid
  end

  specify "content should be at most 280 characters" do
    message.content = "a" * 281
    expect(message).to be_invalid
  end

  specify "order should be most recent first" do
    create(:air, from_user_id: user.id, to_user_id: other_user.id)
    create(:bus, from_user_id: other_user.id, to_user_id: user.id)
    create(:car, from_user_id: user.id, to_user_id: other_user.id)
    expect(most_recent_message).to eq Message.first
  end
end
