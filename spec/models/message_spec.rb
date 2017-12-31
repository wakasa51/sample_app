require 'rails_helper'

RSpec.describe Message, type: :model do
  before do
    @user = create(:michael)
    @other_user = create(:archer)
  end

  let(:message) { Message.new(content: "hello", from_user_id: @other_user.id, to_user_id: @user.id)}

  specify "should be valid" do
    expect(message).to be_valid
  end

  specify "should require a content" do
    message.content = nil
    expect(message).to be_invalid
  end

  specify "should require a from_user_id" do
    message.from_user_id = nil
    expect(message).to be_invalid
  end

  specify "should require a to_user_id" do
    message.to_user_id = nil
    expect(message).to be_invalid
  end

  specify "content should be at most 280 characters" do
    message.content = "a" * 300
    expect(message).to be_invalid
  end
end
