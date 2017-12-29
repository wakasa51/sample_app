require 'rails_helper'

RSpec.describe Message, type: :model do
  describe "factory check" do
    context "use default factory" do
      it "made test data" do
        message = FactoryGirl.create(:message)
        p message
      end
    end
  end
end
