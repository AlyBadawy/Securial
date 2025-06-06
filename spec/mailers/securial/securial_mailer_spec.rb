require "rails_helper"

module Securial
  RSpec.describe SecurialMailer, type: :mailer do
    let(:user) { create(:securial_user) }
    let(:session) { create(:securial_session, user: user) }

    describe "welcome" do
      let(:mail) { described_class.welcome(user) }

      it "renders the headers" do
        expect(mail.subject).to eq(Securial.configuration.mailer_sign_up_subject)
        expect(mail.to).to eq([user.email_address])
        expect(mail.from).to eq(["from@example.com"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Welcome to Securial")
      end
    end

    describe "sign_in" do
      let(:mail) { described_class.sign_in(user, session) }

      it "renders the headers" do
        expect(mail.subject).to eq(Securial.configuration.mailer_sign_in_subject)
        expect(mail.to).to eq([user.email_address])
        expect(mail.from).to eq(["from@example.com"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Sign-in Alert for Securial")
      end
    end

    describe "update_account" do
      let(:mail) { described_class.update_account(user) }

      it "renders the headers" do
        expect(mail.subject).to eq(Securial.configuration.mailer_update_account_subject)
        expect(mail.to).to eq([user.email_address])
        expect(mail.from).to eq(["from@example.com"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Your Account Has Been Updated on Securial")
      end
    end

    describe "forgot_password" do
      let(:mail) { described_class.forgot_password(user) }

      it "renders the headers" do
        expect(mail.subject).to eq(Securial.configuration.mailer_forgot_password_subject)
        expect(mail.to).to eq([user.email_address])
        expect(mail.from).to eq(["from@example.com"])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match("Password Reset Instructions for Securial")
      end
    end
  end
end
