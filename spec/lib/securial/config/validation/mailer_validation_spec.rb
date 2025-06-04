require "rails_helper"

RSpec.describe Securial::Config::Validation::MailerValidation do
  describe ".validate!" do
    let(:config) { instance_double(Securial::Config::Configuration) }

    context "with valid configuration" do
      before do
        allow(config).to receive_messages(
          mailer_sender: "test@domain.com"
        )
      end

      it "does not raise errors" do
        expect { described_class.validate!(config) }.not_to raise_error
      end
    end

    context "with missing mailer sender" do
      before do
        allow(config).to receive_messages(
          mailer_sender: nil
        )
      end

      it "raises MailerValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::MailerValidationError,
          "Mailer sender is not set."
        )
      end
    end

    context "with invalid mailer sender format" do
      before do
        allow(config).to receive_messages(
          mailer_sender: "invalid-email"
        )
      end

      it "raises MailerValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::MailerValidationError,
          "Mailer sender is not a valid email address."
        )
      end
    end
  end
end
