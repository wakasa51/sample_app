require 'rails_helper'

RSpec.describe DevApp, type: :model do
  let(:sample_app) { create(:twtr) }

  it "should be valid" do
    expect(sample_app).to be_valid
  end

  it "should require a app_name" do
    sample_app.app_name = nil
    expect(sample_app).to be_invalid
  end

  it "should require a app_name" do
    sample_app.app_name = nil
    expect(sample_app).to be_invalid
  end

  it "should require a user_id" do
    sample_app.user_id = nil
    expect(sample_app).to be_invalid
  end

  it "should require a contact_mail" do
    sample_app.contact_mail = nil
    expect(sample_app).to be_invalid
  end

  specify "contact_mail should be at most 250 characters" do
    sample_app.contact_mail = "a" * 251
    expect(sample_app).to be_invalid
  end

  it "should require a consumer_id" do
    sample_app.consumer_id = nil
    expect(sample_app).to be_invalid
  end

  specify "consumer_id should be at most 50 characters" do
    sample_app.consumer_id = "a" * 51
    expect(sample_app).to be_invalid
  end

  it "should require a consumer_secret" do
    sample_app.consumer_secret = nil
    expect(sample_app).to be_invalid
  end

  specify "consumer_secret should be at most 100 characters" do
    sample_app.consumer_secret = "a" * 101
    expect(sample_app).to be_invalid
  end

  it "should require a callback_url" do
    sample_app.callback_url = nil
    expect(sample_app).to be_invalid
  end

  specify "callback_url should be at most 350 characters" do
    sample_app.callback_url = "a" * 351
    expect(sample_app).to be_invalid
  end
end
