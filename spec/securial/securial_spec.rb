require "rails_helper"

RSpec.describe Securial do
  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(instance_of(Securial::Configuration))
    end

    it "allows setting configuration values" do
      described_class.configure do |config|
        config.log_to_file = true
        config.log_to_stdout = false
        config.log_file_level = :debug
      end

      expect(described_class.configuration.log_to_file).to be true
      expect(described_class.configuration.log_to_stdout).to be false
      expect(described_class.configuration.log_file_level).to eq :debug
    end

    it "maintains configuration between calls" do
      described_class.configure do |config|
        config.log_to_file = true
      end

      described_class.configure do |config|
        config.log_to_stdout = true
      end

      expect(described_class.configuration.log_to_file).to be true
      expect(described_class.configuration.log_to_stdout).to be true
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(Securial::Configuration)
    end

    it "memoizes the configuration" do
      config1 = described_class.configuration
      config2 = described_class.configuration

      expect(config1).to be(config2)
    end

    it "allows setting a custom configuration" do
      custom_config = Securial::Configuration.new
      described_class.configuration = custom_config

      expect(described_class.configuration).to be(custom_config)
    end

    it "creates a new configuration if none exists" do
      described_class.configuration = nil
      expect(described_class.configuration).to be_a(Securial::Configuration)
    end
  end

  describe ".validate_admin_role!" do
    let(:error_message) { "The admin role cannot be 'account' or 'accounts' as it conflicts with the default routes." }

    before do
      # Reset configuration before each test
      described_class.configuration = Securial::Configuration.new
    end

    context "when admin_role conflicts with accounts namespace" do
      it 'raises error when admin_role is "account"' do
        described_class.configuration.admin_role = "account"

        expect {
          described_class.send(:validate_admin_role!)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, error_message)
      end

      it 'raises error when admin_role is "accounts"' do
        described_class.configuration.admin_role = "accounts"

        expect {
          described_class.send(:validate_admin_role!)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, error_message)
      end
    end

    context "when admin_role is valid" do
      it "does not raise error for valid role names" do
        valid_roles = ["manager", "supervisor", "moderator"]

        valid_roles.each do |role|
          described_class.configuration.admin_role = role
          expect {
            described_class.send(:validate_admin_role!)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_session_expiry_duration!" do
    around do |example|
      # Reset configuration before each test
      described_class.configuration = Securial::Configuration.new
      example.run
    end

    context "when session_expiration_duration is nil" do
      it "raises ConfigSessionExpirationDurationError" do
        described_class.configuration.session_expiration_duration = nil
        expect {
          described_class.send(:validate_session_expiry_duration!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionExpirationDurationError,
          "Session expiration duration is not set."
        )
      end
    end

    context "when session_expiration_duration is not an ActiveSupport::Duration" do
      it "raises ConfigSessionExpirationDurationError" do
        described_class.configuration.session_expiration_duration = 3600 # integer instead of duration
        expect {
          described_class.send(:validate_session_expiry_duration!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionExpirationDurationError,
          "Session expiration duration must be an ActiveSupport::Duration."
        )
      end
    end

    context "when session_expiration_duration is less than or equal to 0" do
      it "raises ConfigSessionExpirationDurationError for 0" do
        described_class.configuration.session_expiration_duration = 0.minutes
        expect {
          described_class.send(:validate_session_expiry_duration!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionExpirationDurationError,
          "Session expiration duration must be greater than 0."
        )
      end

      it "raises ConfigSessionExpirationDurationError for negative duration" do
        described_class.configuration.session_expiration_duration = -1.hour
        expect {
          described_class.send(:validate_session_expiry_duration!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionExpirationDurationError,
          "Session expiration duration must be greater than 0."
        )
      end
    end

    context "when session_expiration_duration is valid" do
      it "does not raise error for valid duration" do
        valid_durations = [1.minute, 1.hour, 12.hours, 24.hours]
        valid_durations.each do |duration|
          described_class.configuration.session_expiration_duration = duration
          expect {
            described_class.send(:validate_session_expiry_duration!)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_session_algorithm!" do
    around do |example|
      described_class.configuration = Securial::Configuration.new
      example.run
    end

    context "when session_algorithm is invalid" do
      it "raises ConfigSessionAlgorithmError for nil value" do
        described_class.configuration.session_algorithm = nil
        expect {
          described_class.send(:validate_session_algorithm!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionAlgorithmError,
          "Invalid session algorithm. Valid options are: :hs256, :hs384, :hs512."
        )
      end

      it "raises ConfigSessionAlgorithmError for invalid algorithm" do
        invalid_algorithms = [:rs256, :invalid_algo, :none]
        invalid_algorithms.each do |algorithm|
          described_class.configuration.session_algorithm = algorithm
          expect {
            described_class.send(:validate_session_algorithm!)
          }.to raise_error(
            Securial::ConfigErrors::ConfigSessionAlgorithmError,
            "Invalid session algorithm. Valid options are: :hs256, :hs384, :hs512."
          )
        end
      end
    end

    context "when session_algorithm is valid" do
      it "does not raise error for valid algorithms" do
        valid_algorithms = [:hs256, :hs384, :hs512]
        valid_algorithms.each do |algorithm|
          described_class.configuration.session_algorithm = algorithm
          expect {
            described_class.send(:validate_session_algorithm!)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_session_secret!" do
    around do |example|
      described_class.configuration = Securial::Configuration.new
      example.run
    end

    context "when session_secret is invalid" do
      it "raises ConfigSessionSecretError for nil value" do
        described_class.configuration.session_secret = nil
        expect {
          described_class.send(:validate_session_secret!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionSecretError,
          "Session secret is not set."
        )
      end

      it "raises ConfigSessionSecretError for empty string" do
        described_class.configuration.session_secret = ""
        expect {
          described_class.send(:validate_session_secret!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionSecretError,
          "Session secret is not set."
        )
      end

      it "raises ConfigSessionSecretError for blank string" do
        described_class.configuration.session_secret = "   "
        expect {
          described_class.send(:validate_session_secret!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionSecretError,
          "Session secret is not set."
        )
      end
    end

    context "when session_secret is valid" do
      it "does not raise error for non-blank secret" do
        valid_secrets = [
          "some_secret_key",
          "12345678901234567890",
          SecureRandom.hex(32)
        ]
        valid_secrets.each do |secret|
          described_class.configuration.session_secret = secret
          expect {
            described_class.send(:validate_session_secret!)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_mailer_sender!" do
    around do |example|
      described_class.configuration = Securial::Configuration.new
      example.run
    end

    context 'when mailer_sender is not set' do
      it 'raises ConfigMailerSenderError' do
        described_class.configuration.mailer_sender = nil
        expect {
          described_class.validate_mailer_sender!
        }.to raise_error(
          Securial::ConfigErrors::ConfigMailerSenderError,
          'Mailer sender is not set.'
        )
      end
    end

    context 'when mailer_sender is blank' do
      it 'raises ConfigMailerSenderError' do
        described_class.configuration.mailer_sender = ''
        expect {
          described_class.validate_mailer_sender!
        }.to raise_error(
          Securial::ConfigErrors::ConfigMailerSenderError,
          'Mailer sender is not set.'
        )
      end
    end

    context 'when mailer_sender is not a valid email' do
      it 'raises ConfigMailerSenderError' do
        described_class.configuration.mailer_sender = 'invalid-email'
        expect {
          described_class.validate_mailer_sender!
        }.to raise_error(
          Securial::ConfigErrors::ConfigMailerSenderError,
          'Mailer sender is not a valid email address.'
        )
      end
    end

    context 'when mailer_sender is valid' do
      it 'does not raise an error' do
        described_class.configuration.mailer_sender = 'valid@example.com'
        expect {
          described_class.validate_mailer_sender!
        }.not_to raise_error
      end
    end
  end

  describe "validate_password_config!" do
    around do |example|
      described_class.configuration = Securial::Configuration.new
      example.run
    end

    context 'when password_reset_email_subject is not set' do
      it 'raises ConfigMailerSenderError' do
        described_class.configuration.password_reset_email_subject = nil
        expect {
          described_class.validate_password_config!
        }.to raise_error(
          Securial::ConfigErrors::ConfigMailerSenderError,
          'Password reset email subject is not set.'
        )
      end
    end

    context 'when password_reset_email_subject is blank' do
      it 'raises ConfigMailerSenderError' do
        described_class.configuration.password_reset_email_subject = ''
        expect {
          described_class.validate_password_config!
        }.to raise_error(
          Securial::ConfigErrors::ConfigMailerSenderError,
          'Password reset email subject is not set.'
        )
      end
    end

    context 'when password_reset_email_subject is valid' do
      it 'does not raise an error' do
        described_class.configuration.password_reset_email_subject = 'Reset Your Password'
        expect {
          described_class.validate_password_config!
        }.not_to raise_error
      end
    end
  end

  describe "validate_timestamps_in_response!" do
    around do |example|
      described_class.configuration = Securial::Configuration.new
      example.run
    end

    context "when timestamps_in_response is invalid" do
      it "raises ConfigTimestampsInResponseError for nil value" do
        described_class.configuration.timestamps_in_response = nil
        expect {
          described_class.send(:validate_timestamps_in_response!)
        }.to raise_error(
          Securial::ConfigErrors::ConfigTimestampsInResponseError,
          "Invalid timestamps_in_response option. Valid options are: :all, :admins_only, :none."
        )
      end


      it "raises ConfigTimestampsInResponseError for invalid values" do
        invalid_options = [:created_at, :updated_at, :invalid_option]
        invalid_options.each do |option|
          described_class.configuration.timestamps_in_response = option
          expect {
            described_class.send(:validate_timestamps_in_response!)
          }.to raise_error(
            Securial::ConfigErrors::ConfigTimestampsInResponseError,
            "Invalid timestamps_in_response option. Valid options are: :all, :admins_only, :none."
          )
        end
      end
    end

    context "when timestamps_in_response is valid" do
      it "does not raise error for valid algorithms" do
        valid_options = [:none, :admins_only, :all]
        valid_options.each do |option|
          described_class.configuration.timestamps_in_response = option
          expect {
            described_class.send(:validate_timestamps_in_response!)
          }.not_to raise_error
        end
      end
    end
  end
end
