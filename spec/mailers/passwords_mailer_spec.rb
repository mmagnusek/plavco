require "rails_helper"

RSpec.describe PasswordsMailer, type: :mailer do
  describe "#reset" do
    let(:user) { create(:user, email_address: "test@example.com", name: "John Doe") }
    let(:mail) { described_class.reset(user) }

    it "sends the email to the user's email address" do
      expect(mail.to).to eq([user.email_address])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Reset your password")
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["info@rozpiska.cz"])
    end

    it "renders the HTML template" do
      expect(mail.html_part.body.to_s).to include("You can reset your password")
      expect(mail.html_part.body.to_s).to include("this password reset page")
    end

    it "renders the text template" do
      expect(mail.text_part.body.to_s).to include("You can reset your password")
      expect(mail.text_part.body.to_s).to include("password reset page")
    end

    it "includes the password reset link in the HTML email" do
      expect(mail.text_part.body.to_s).to match(/\/passwords\/.*\/edit/)
    end

    it "includes the password reset link in the text email" do
      expect(mail.text_part.body.to_s).to match(/\/passwords\/.*\/edit/)
    end
  end
end
