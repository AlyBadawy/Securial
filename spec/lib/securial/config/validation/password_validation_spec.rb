require "spec_helper"

RSpec.describe Securial::Config::Validation::PasswordValidation do
  let(:config) do
    Struct.new(
      :reset_password_token_secret,
      :password_reset_email_subject,
      :password_min_length,
      :password_max_length,
      :password_complexity,
      :password_expires,
      :password_expires_in
    ).new(
      "secret",
      "Reset your password",
      8,
      64,
      /(?=.*[A-Z])/,
      true,
      30.days
    )
  end

  before do
    stub_const("Securial::Error::Config::PasswordValidationError", Class.new(StandardError))
    allow(Securial).to receive(:logger).and_return(instance_double(Logger, fatal: nil))
  end

  describe ".validate!" do
    it "calls all validation methods" do
      allow(described_class).to receive(:validate_password_reset_subject!).and_call_original
      allow(described_class).to receive(:validate_password_min_max_length!).and_call_original
      allow(described_class).to receive(:validate_password_complexity!).and_call_original
      allow(described_class).to receive(:validate_password_expiration!).and_call_original
      allow(described_class).to receive(:validate_password_reset_token!).and_call_original

      described_class.validate!(config)

      expect(described_class).to have_received(:validate_password_reset_subject!).with(config)
      expect(described_class).to have_received(:validate_password_min_max_length!).with(config)
      expect(described_class).to have_received(:validate_password_complexity!).with(config)
      expect(described_class).to have_received(:validate_password_expiration!).with(config)
      expect(described_class).to have_received(:validate_password_reset_token!).with(config)
    end
  end

  describe ".validate_password_reset_subject!" do
    it "raises if password_reset_email_subject is blank" do
      config.password_reset_email_subject = ""
      expect {
        described_class.send(:validate_password_reset_subject!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password reset email subject is not set.")
    end

    it "raises if password_reset_email_subject is nil" do
      config.password_reset_email_subject = nil
      expect {
        described_class.send(:validate_password_reset_subject!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password reset email subject is not set.")
    end

    it "raises if password_reset_email_subject is not a String" do
      config.password_reset_email_subject = 123
      expect {
        described_class.send(:validate_password_reset_subject!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password reset email subject must be a String.")
    end

    it "does not raise on valid subject" do
      config.password_reset_email_subject = "Reset your password"
      expect {
        described_class.send(:validate_password_reset_subject!, config)
      }.not_to raise_error
    end
  end

  describe ".validate_password_min_max_length!" do
    describe "min length" do
      it "raises if min_length is nil" do
        config.password_min_length = nil
        expect {
          described_class.send(:validate_password_min_max_length!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password minimum length must be a positive integer.")
      end

      it "raises if min_length is not an integer" do
        config.password_min_length = "8"
        expect {
          described_class.send(:validate_password_min_max_length!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password minimum length must be a positive integer.")
      end

      it "raises if min_length <= 0" do
        config.password_min_length = 0
        expect {
          described_class.send(:validate_password_min_max_length!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password minimum length must be a positive integer.")

        config.password_min_length = -1
        expect {
          described_class.send(:validate_password_min_max_length!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password minimum length must be a positive integer.")
      end

      it "does not raise for valid min_length" do
        [1, 8, 20].each do |valid|
          config.password_min_length = valid
          config.password_max_length = valid + 1
          expect {
            described_class.send(:validate_password_min_max_length!, config)
          }.not_to raise_error
        end
      end
    end

    describe "max length" do
      it "raises if max_length is nil" do
        config.password_max_length = nil
        expect {
          described_class.send(:validate_password_min_max_length!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password maximum length must be an integer greater than or equal to the minimum length.")
      end

      it "raises if max_length is not an integer" do
        config.password_max_length = "100"
        expect {
          described_class.send(:validate_password_min_max_length!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password maximum length must be an integer greater than or equal to the minimum length.")
      end

      it "raises if max_length < min_length" do
        config.password_min_length = 10
        config.password_max_length = 5
        expect {
          described_class.send(:validate_password_min_max_length!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password maximum length must be an integer greater than or equal to the minimum length.")
      end

      it "does not raise for valid max_length" do
        config.password_min_length = 3
        [3, 8, 20].each do |valid|
          config.password_max_length = valid
          expect {
            described_class.send(:validate_password_min_max_length!, config)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_password_complexity!" do
    it "raises if complexity is nil" do
      config.password_complexity = nil
      expect {
        described_class.send(:validate_password_complexity!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password complexity regex is not set or is not a valid Regexp.")
    end

    it "raises if complexity is not a Regexp" do
      config.password_complexity = "foo"
      expect {
        described_class.send(:validate_password_complexity!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password complexity regex is not set or is not a valid Regexp.")
    end

    it "does not raise for valid regex" do
      config.password_complexity = /foo/
      expect {
        described_class.send(:validate_password_complexity!, config)
      }.not_to raise_error
    end
  end

  describe ".validate_password_expiration!" do
    it "raises if password_expires not a boolean" do
      config.password_expires = "true"
      expect {
        described_class.send(:validate_password_expiration!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password expiration must be a boolean value.")
    end

    it "does not raise if password_expires is false and expires_in is nil" do
      config.password_expires = false
      config.password_expires_in = nil
      expect {
        described_class.send(:validate_password_expiration!, config)
      }.not_to raise_error
    end

    context "when password_expires is true" do
      before { config.password_expires = true }

      it "raises if password_expires_in is nil" do
        config.password_expires_in = nil
        expect {
          described_class.send(:validate_password_expiration!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password expiration duration is not set or is not a valid ActiveSupport::Duration.")
      end

      it "raises if password_expires_in is not an ActiveSupport::Duration" do
        config.password_expires_in = 30
        expect {
          described_class.send(:validate_password_expiration!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password expiration duration is not set or is not a valid ActiveSupport::Duration.")
      end

      it "raises if password_expires_in <= 0" do
        config.password_expires_in = 0.minutes
        expect {
          described_class.send(:validate_password_expiration!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password expiration duration is not set or is not a valid ActiveSupport::Duration.")

        config.password_expires_in = -1.hour
        expect {
          described_class.send(:validate_password_expiration!, config)
        }.to raise_error(Securial::Error::Config::PasswordValidationError, "Password expiration duration is not set or is not a valid ActiveSupport::Duration.")
      end

      it "does not raise for valid durations" do
        [1.day, 7.days, 30.days].each do |duration|
          config.password_expires_in = duration
          expect {
            described_class.send(:validate_password_expiration!, config)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_password_reset_token!" do
    it "raises if reset_password_token_secret is blank" do
      config.reset_password_token_secret = ""
      expect {
        described_class.send(:validate_password_reset_token!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Reset password token secret is not set.")
    end

    it "raises if reset_password_token_secret is nil" do
      config.reset_password_token_secret = nil
      expect {
        described_class.send(:validate_password_reset_token!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Reset password token secret is not set.")
    end

    it "raises if reset_password_token_secret is not a String" do
      config.reset_password_token_secret = 123
      expect {
        described_class.send(:validate_password_reset_token!, config)
      }.to raise_error(Securial::Error::Config::PasswordValidationError, "Reset password token secret must be a String.")
    end

    it "does not raise for valid secret" do
      config.reset_password_token_secret = "some_secret_key"
      expect {
        described_class.send(:validate_password_reset_token!, config)
      }.not_to raise_error
    end
  end
end
