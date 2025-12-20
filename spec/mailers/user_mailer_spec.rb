require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#notify_free_spot" do
    let(:user) { create(:user, email_address: "test@example.com", name: "John Doe", locale: "en", trainers: [trainer]) }
    let(:slot) { create(:slot, day_of_week: 1, starts_at: "10:00:00", ends_at: "10:45:00", trainer: trainer) }
    let(:week_start) { Date.current.beginning_of_week }
    let(:mail) { described_class.with(user: user, slot: slot, week_start: week_start).notify_free_spot }

    it "sends the email to the user's email address" do
      expect(mail.to).to eq([user.email_address])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("A spot is now available for your waitlist slot")
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["info@rozpiska.cz"])
    end

    it "renders the HTML template with slot information" do
      expect(mail.html_part.body.to_s).to include("Good news!")
      expect(mail.html_part.body.to_s).to include(slot.to_label)
    end

    it "includes the calendar link in the HTML email" do
      expect(mail.html_part.body.to_s).to include("Book Now")
      expect(mail.html_part.body.to_s).to match(/calendar\?week=#{week_start.strftime('%Y-%m-%d')}/)
    end

    context "when user has Czech locale" do
      let(:user) { create(:user, email_address: "test@example.com", name: "Jan Novák", locale: "cs") }

      it "uses Czech translation for subject" do
        expect(mail.subject).to eq("Místo je nyní dostupné pro váš termín na čekací listině")
      end

      it "uses Czech translation in the email body" do
        expect(mail.html_part.body.to_s).to include("Dobré zprávy!")
        expect(mail.html_part.body.to_s).to include("Rezervovat nyní")
      end
    end

    it "includes week_start in the email" do
      formatted_week_start = I18n.l(week_start, format: :long, locale: user.locale)
      expect(mail.html_part.body.to_s).to include(formatted_week_start)
    end
  end
end
