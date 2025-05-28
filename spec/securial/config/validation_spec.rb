require "rails_helper"
RSpec.describe Securial::Config::Validation do
  let(:config) { Securial::Config::Configuration.new }

  describe ".validate_all!" do
    it "validates all configuration settings" do
      allow(described_class).to receive(:validate_admin_role!)
      allow(described_class).to receive(:validate_session_config!)
      allow(described_class).to receive(:validate_mailer_sender!)
      allow(described_class).to receive(:validate_password_config!)
      allow(described_class).to receive(:validate_timestamps_in_response!)

      described_class.send(:validate_all!, config)

      expect(described_class).to have_received(:validate_admin_role!).with(config)
      expect(described_class).to have_received(:validate_session_config!).with(config)
      expect(described_class).to have_received(:validate_mailer_sender!).with(config)
      expect(described_class).to have_received(:validate_password_config!).with(config)
      expect(described_class).to have_received(:validate_timestamps_in_response!).with(config)
    end
  end

  describe ".validate_admin_role!" do
    let(:error_message) { "The admin role cannot be 'account' or 'accounts' as it conflicts with the default routes." }

    context "when admin_role is nil" do
      it "raises ConfigAdminRoleError" do
        config.admin_role = nil
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, "Admin role is not set.")
      end
    end

    context "when admin_role is blank" do
      it "raises ConfigAdminRoleError for empty string" do
        config.admin_role = ""
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, "Admin role is not set.")
      end

      it "raises ConfigAdminRoleError for whitespace string" do
        config.admin_role = "   "
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, "Admin role is not set.")
      end
    end

    context "when admin_role is not a Symbol or String" do
      it "raises ConfigAdminRoleError for Integer" do
        config.admin_role = 123
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, "Admin role must be a Symbol or String.")
      end

      it "raises ConfigAdminRoleError for Array" do
        config.admin_role = [:admin]
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, "Admin role must be a Symbol or String.")
      end
    end

    context "when admin_role conflicts with accounts namespace" do
      it 'raises error when admin_role is "account"' do
        config.admin_role = "account"

        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, error_message)
      end

      it 'raises error when admin_role is "accounts"' do
        config.admin_role = "accounts"

        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::ConfigErrors::ConfigAdminRoleError, error_message)
      end
    end

    context "when admin_role is valid" do
      it "does not raise error for valid role names" do
        valid_roles = ["manager", "supervisor", :moderator]

        valid_roles.each do |role|
          config.admin_role = role
          expect {
            described_class.send(:validate_admin_role!, config)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_session_config!" do
    it "validates all configuration settings" do # rubocop:disable RSpec/MultipleExpectations
      allow(described_class).to receive(:validate_session_expiry_duration!)
      allow(described_class).to receive(:validate_session_algorithm!)
      allow(described_class).to receive(:validate_session_secret!)

      described_class.send(:validate_session_config!, config)

      expect(described_class).to have_received(:validate_session_expiry_duration!).with(config)
      expect(described_class).to have_received(:validate_session_algorithm!).with(config)
      expect(described_class).to have_received(:validate_session_secret!).with(config)
    end
  end

  describe ".validate_session_expiry_duration!" do
    context "when session_expiration_duration is nil" do
      it "raises ConfigSessionExpirationDurationError" do
        config.session_expiration_duration = nil
        expect {
          described_class.send(:validate_session_expiry_duration!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionExpirationDurationError,
          "Session expiration duration is not set."
        )
      end
    end

    context "when session_expiration_duration is not an ActiveSupport::Duration" do
      it "raises ConfigSessionExpirationDurationError" do
        config.session_expiration_duration = 3600 # integer instead of duration
        expect {
          described_class.send(:validate_session_expiry_duration!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionExpirationDurationError,
          "Session expiration duration must be an ActiveSupport::Duration."
        )
      end
    end

    context "when session_expiration_duration is less than or equal to 0" do
      it "raises ConfigSessionExpirationDurationError for 0" do
        config.session_expiration_duration = 0.minutes
        expect {
          described_class.send(:validate_session_expiry_duration!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionExpirationDurationError,
          "Session expiration duration must be greater than 0."
        )
      end

      it "raises ConfigSessionExpirationDurationError for negative duration" do
        config.session_expiration_duration = -1.hour
        expect {
          described_class.send(:validate_session_expiry_duration!, config)
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
          config.session_expiration_duration = duration
          expect {
            described_class.send(:validate_session_expiry_duration!, config)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_session_algorithm!" do
    context "when session_algorithm is not set" do
      it "raises ConfigSessionAlgorithmError for nil value" do
        config.session_algorithm = nil
        expect {
          described_class.send(:validate_session_algorithm!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionAlgorithmError,
          "Session algorithm is not set."
        )
      end
    end

    context "when session_algorithm is not a Symbol" do
      it "raises ConfigSessionAlgorithmError for String" do
        config.session_algorithm = "hs256"
        expect {
          described_class.send(:validate_session_algorithm!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionAlgorithmError,
          "Session algorithm must be a Symbol."
        )
      end
    end

    context "when session_algorithm is invalid" do
      it "raises ConfigSessionAlgorithmError for invalid algorithm" do
        invalid_algorithms = [:invalid_algo, :none]
        invalid_algorithms.each do |algorithm|
          config.session_algorithm = algorithm
          expect {
            described_class.send(:validate_session_algorithm!, config)
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
          config.session_algorithm = algorithm
          expect {
            described_class.send(:validate_session_algorithm!, config)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_session_secret!" do
    context "when session_secret is not set" do
      it "raises ConfigSessionSecretError for nil value" do
        config.session_secret = nil
        expect {
          described_class.send(:validate_session_secret!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionSecretError,
          "Session secret is not set."
        )
      end

      it "raises ConfigSessionSecretError for empty string" do
        config.session_secret = ""
        expect {
          described_class.send(:validate_session_secret!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionSecretError,
          "Session secret is not set."
        )
      end

      it "raises ConfigSessionSecretError for blank string" do
        config.session_secret = "   "
        expect {
          described_class.send(:validate_session_secret!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionSecretError,
          "Session secret is not set."
        )
      end
    end

    context "when session_secret is not a String" do
      it "raises ConfigSessionSecretError for Integer" do
        config.session_secret = 12345
        expect {
          described_class.send(:validate_session_secret!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionSecretError,
          "Session secret must be a String."
        )
      end

      it "raises ConfigSessionSecretError for Array" do
        config.session_secret = ["secret"]
        expect {
          described_class.send(:validate_session_secret!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigSessionSecretError,
          "Session secret must be a String."
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
          config.session_secret = secret
          expect {
            described_class.send(:validate_session_secret!, config)
          }.not_to raise_error
        end
      end
    end
  end

  describe ".validate_mailer_sender!" do
    context "when mailer_sender is not set" do
      it "raises ConfigMailerSenderError" do
        config.mailer_sender = nil
        expect {
          described_class.send(:validate_mailer_sender!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigMailerSenderError,
          "Mailer sender is not set."
        )
      end
    end

    context "when mailer_sender is blank" do
      it "raises ConfigMailerSenderError" do
        config.mailer_sender = ""
        expect {
          described_class.send(:validate_mailer_sender!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigMailerSenderError,
          "Mailer sender is not set."
        )
      end
    end

    context "when mailer_sender is not a valid email" do
      it "raises ConfigMailerSenderError" do
        config.mailer_sender = "invalid-email"
        expect {
          described_class.send(:validate_mailer_sender!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigMailerSenderError,
          "Mailer sender is not a valid email address."
        )
      end
    end

    context "when mailer_sender is valid" do
      it "does not raise an error" do
        config.mailer_sender = "valid@example.com"
        expect {
          described_class.send(:validate_mailer_sender!, config)
        }.not_to raise_error
      end
    end
  end

  describe "validate_password_config!" do
    it "validates all password configuration settings" do
      allow(described_class).to receive(:validate_password_reset_subject!)
      allow(described_class).to receive(:validate_password_min_max_length!)
      allow(described_class).to receive(:validate_password_complexity!)
      allow(described_class).to receive(:validate_password_expiration!)
      allow(described_class).to receive(:validate_password_reset_token!)

      described_class.send(:validate_password_config!, config)

      expect(described_class).to have_received(:validate_password_reset_subject!).with(config)
      expect(described_class).to have_received(:validate_password_min_max_length!).with(config)
      expect(described_class).to have_received(:validate_password_complexity!).with(config)
      expect(described_class).to have_received(:validate_password_expiration!).with(config)
      expect(described_class).to have_received(:validate_password_reset_token!).with(config)
    end
  end

  describe "validate_password_reset_subject!" do
    context "when password_reset_email_subject is not set" do
      it "raises ConfigPasswordError" do
        config.password_reset_email_subject = nil
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password reset email subject is not set."
        )
      end
    end

    context "when password_reset_email_subject is blank" do
      it "raises ConfigMailerSenderError" do
        config.password_reset_email_subject = ""
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password reset email subject is not set."
        )
      end
    end

    context "when password_reset_email_subject is not a String" do
      it "raises ConfigPasswordError for Integer" do
        config.password_reset_email_subject = 12345
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password reset email subject must be a String."
        )
      end

      it "raises ConfigPasswordError for Array" do
        config.password_reset_email_subject = ["Reset Password"]
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password reset email subject must be a String."
        )
      end
    end

    context "when password_reset_email_subject is valid" do
      it "does not raise an error" do
        config.password_reset_email_subject = "Reset Your Password"
        expect {
          described_class.send(:validate_password_config!, config)
        }.not_to raise_error
      end
    end
  end

  describe "validate_password_min_max_length!" do
    describe "minimum length for password" do
      context "when password_min_length is not set" do
        it "raises ConfigPasswordError" do
          config.password_min_length = nil
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password minimum length must be a positive integer."
          )
        end
      end

      context "when password_min_length is not an Integer" do
        it "raises ConfigPasswordError for String" do
          config.password_min_length = "8"
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password minimum length must be a positive integer."
          )
        end

        it "raises ConfigPasswordError for Array" do
          config.password_min_length = [8]
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password minimum length must be a positive integer."
          )
        end
      end

      context "when password_min_length is less than or equal to 0" do
        it "raises ConfigPasswordError for 0" do
          config.password_min_length = 0
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password minimum length must be a positive integer."
          )
        end

        it "raises ConfigPasswordError for negative value" do
          config.password_min_length = -1
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password minimum length must be a positive integer."
          )
        end
      end

      context "when password_min_length is valid" do
        it "does not raise error for valid lengths" do
          valid_lengths = [8, 12, 16]
          valid_lengths.each do |length|
            config.password_min_length = length
            expect {
              described_class.send(:validate_password_config!, config)
            }.not_to raise_error
          end
        end
      end
    end

    describe "maximum length for password" do
      context "when password_max_length is not set" do
        it "raises ConfigPasswordError" do
          config.password_max_length = nil
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password maximum length must be an integer greater than or equal to the minimum length."
          )
        end
      end

      context "when password_max_length is not an Integer" do
        it "raises ConfigPasswordError for String" do
          config.password_max_length = "20"
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password maximum length must be an integer greater than or equal to the minimum length."
          )
        end

        it "raises ConfigPasswordError for Array" do
          config.password_max_length = [20]
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password maximum length must be an integer greater than or equal to the minimum length."
          )
        end
      end

      context "when password_max_length is less than password_min_length" do
        before { config.password_min_length = 10 }

        it "raises ConfigPasswordError for less than min length" do
          config.password_max_length = 5
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::ConfigErrors::ConfigPasswordError,
            "Password maximum length must be an integer greater than or equal to the minimum length."
          )
        end
      end

      context "when password_max_length is valid" do
        it "does not raise error for valid lengths" do
          valid_lengths = [10, 12, 16, 20]
          valid_lengths.each do |length|
            config.password_max_length = length
            expect {
              described_class.send(:validate_password_config!, config)
            }.not_to raise_error
          end
        end
      end
    end
  end

  describe "validate_password_complexity!" do
    context "when password_complexity is not set" do
      it "raises ConfigPasswordError" do
        config.password_complexity = nil
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password complexity regex is not set or is not a valid Regexp."
        )
      end
    end

    context "when password_complexity is not a Regexp" do
      it "raises ConfigPasswordError for String" do
        config.password_complexity = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$"
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password complexity regex is not set or is not a valid Regexp."
        )
      end

      it "raises ConfigPasswordError for Integer" do
        config.password_complexity = 12345
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password complexity regex is not set or is not a valid Regexp."
        )
      end
    end

    context "when password_complexity is valid" do
      it "does not raise error for valid regex" do
        config.password_complexity = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/
        expect {
          described_class.send(:validate_password_config!, config)
        }.not_to raise_error
      end
    end
  end

  describe "validate_password_expiration!" do
    context "when password_expires_in is not set" do
      it "raises ConfigPasswordError" do
        config.password_expires_in = nil
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password expiration duration is not set or is not a valid ActiveSupport::Duration."
        )
      end
    end

    context "when password_expires_in is not an ActiveSupport::Duration" do
      it "raises ConfigPasswordError for Integer" do
        config.password_expires_in = 30 # integer instead of duration
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password expiration duration is not set or is not a valid ActiveSupport::Duration."
        )
      end
    end

    context "when password_expires_in is less than or equal to 0" do
      it "raises ConfigPasswordError for 0" do
        config.password_expires_in = 0.minutes
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password expiration duration is not set or is not a valid ActiveSupport::Duration."
        )
      end

      it "raises ConfigPasswordError for negative duration" do
        config.password_expires_in = -1.hour
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Password expiration duration is not set or is not a valid ActiveSupport::Duration."
        )
      end
    end

    context "when password_expires_in is valid" do
      it "does not raise error for valid durations" do
        valid_durations = [1.day, 7.days, 30.days]
        valid_durations.each do |duration|
          config.password_expires_in = duration
          expect {
            described_class.send(:validate_password_config!, config)
          }.not_to raise_error
        end
      end
    end
  end

  describe "validate_password_reset_token!" do
    context "when reset_password_token_secret is not set" do
      it "raises ConfigPasswordError" do
        config.reset_password_token_secret = nil
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Reset password token secret is not set."
        )
      end
    end

    context "when reset_password_token_secret is not a String" do
      it "raises ConfigPasswordError for Integer" do
        config.reset_password_token_secret = 12345
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Reset password token secret must be a String."
        )
      end

      it "raises ConfigPasswordError for Array" do
        config.reset_password_token_secret = ["secret"]
        expect {
          described_class.send(:validate_password_config!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigPasswordError,
          "Reset password token secret must be a String."
        )
      end
    end

    context "when reset_password_token_secret is valid" do
      it "does not raise error for non-blank secret" do
        config.reset_password_token_secret = "some_secret_key"
        expect {
          described_class.send(:validate_password_config!, config)
        }.not_to raise_error
      end
    end
  end

  describe "validate_timestamps_in_response!" do
    context "when timestamps_in_response is invalid" do
      it "raises ConfigTimestampsInResponseError for nil value" do
        config.timestamps_in_response = nil
        expect {
          described_class.send(:validate_timestamps_in_response!, config)
        }.to raise_error(
          Securial::ConfigErrors::ConfigTimestampsInResponseError,
          "Invalid timestamps_in_response option. Valid options are: :all, :admins_only, :none."
        )
      end

      it "raises ConfigTimestampsInResponseError for invalid values" do
        invalid_options = [:created_at, :updated_at, :invalid_option]
        invalid_options.each do |option|
          config.timestamps_in_response = option
          expect {
            described_class.send(:validate_timestamps_in_response!, config)
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
          config.timestamps_in_response = option
          expect {
            described_class.send(:validate_timestamps_in_response!, config)
          }.not_to raise_error
        end
      end
    end
  end
end
