require 'rails_helper'

RSpec.describe LinkedApp, type: :model do
  let(:saisyo){ create(:saisyo) }

  it "should be valid" do
    expect(saisyo).to be_valid
  end

  it "should require a user_id" do
    saisyo.user_id = nil
    expect(saisyo).to be_invalid
  end

  it "should require a dev_app_id" do
    saisyo.dev_app_id = nil
    expect(saisyo).to be_invalid
  end
end
