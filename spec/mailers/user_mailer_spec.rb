require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "follow_notice" do
    let(:mail) { UserMailer.follow_notice(user, follower) }
    let(:user) { create(:michael) }
    let(:follower) { create(:archer) }

    it "renders the headers" do
      expect(mail.subject).to eq("New follower")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(user.name)
      expect(mail.body.encoded).to match("@#{follower.id}-#{follower.name.gsub(' ', '-')}")
    end
  end

end
