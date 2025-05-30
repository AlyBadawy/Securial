require "rails_helper"

# rubocop:disable RSpec/NestedGroups
RSpec.describe Securial::Config::Validation do
  let(:config) { Securial::Config::Configuration.new }

  before do
    allow(config).to receive(:validate!).and_return(true)
  end

  describe ".validate_all!" do
    it "validates all configuration settings" do # rubocop:disable RSpec/MultipleExpectations
      allow(described_class).to receive(:validate_admin_role!)
      allow(described_class).to receive(:validate_session_config!)
      allow(described_class).to receive(:validate_mailer_sender!)
      allow(described_class).to receive(:validate_password_config!)
      allow(described_class).to receive(:validate_response_config!)
      allow(described_class).to receive(:validate_security_config!)

      described_class.send(:validate_all!, config)

      expect(described_class).to have_received(:validate_admin_role!).with(config)
      expect(described_class).to have_received(:validate_session_config!).with(config)
      expect(described_class).to have_received(:validate_mailer_sender!).with(config)
      expect(described_class).to have_received(:validate_password_config!).with(config)
      expect(described_class).to have_received(:validate_response_config!).with(config)
      expect(described_class).to have_received(:validate_security_config!).with(config)
    end
  end

  describe ".validate_admin_role!" do
    let(:error_message) { "The admin role cannot be 'account' or 'accounts' as it conflicts with the default routes." }

    context "when admin_role is nil" do
      it "raises ConfigAdminRoleError" do
        config.admin_role = nil
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::Config::Errors::ConfigAdminRoleError, "Admin role is not set.")
      end
    end

    context "when admin_role is blank" do
      it "raises ConfigAdminRoleError for empty string" do
        config.admin_role = ""
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::Config::Errors::ConfigAdminRoleError, "Admin role is not set.")
      end

      it "raises ConfigAdminRoleError for whitespace string" do
        config.admin_role = "   "
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::Config::Errors::ConfigAdminRoleError, "Admin role is not set.")
      end
    end

    context "when admin_role is not a Symbol or String" do
      it "raises ConfigAdminRoleError for Integer" do
        config.admin_role = 123
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::Config::Errors::ConfigAdminRoleError, "Admin role must be a Symbol or String.")
      end

      it "raises ConfigAdminRoleError for Array" do
        config.admin_role = [:admin]
        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::Config::Errors::ConfigAdminRoleError, "Admin role must be a Symbol or String.")
      end
    end

    context "when admin_role conflicts with accounts namespace" do
      it 'raises error when admin_role is "account"' do
        config.admin_role = "account"

        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::Config::Errors::ConfigAdminRoleError, error_message)
      end

      it 'raises error when admin_role is "accounts"' do
        config.admin_role = "accounts"

        expect {
          described_class.send(:validate_admin_role!, config)
        }.to raise_error(Securial::Config::Errors::ConfigAdminRoleError, error_message)
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

  describe "Session Configuration Validation" do
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
            Securial::Config::Errors::ConfigSessionExpirationDurationError,
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
            Securial::Config::Errors::ConfigSessionExpirationDurationError,
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
            Securial::Config::Errors::ConfigSessionExpirationDurationError,
            "Session expiration duration must be greater than 0."
          )
        end

        it "raises ConfigSessionExpirationDurationError for negative duration" do
          config.session_expiration_duration = -1.hour
          expect {
            described_class.send(:validate_session_expiry_duration!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigSessionExpirationDurationError,
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
            Securial::Config::Errors::ConfigSessionAlgorithmError,
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
            Securial::Config::Errors::ConfigSessionAlgorithmError,
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
              Securial::Config::Errors::ConfigSessionAlgorithmError,
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
            Securial::Config::Errors::ConfigSessionSecretError,
            "Session secret is not set."
          )
        end

        it "raises ConfigSessionSecretError for empty string" do
          config.session_secret = ""
          expect {
            described_class.send(:validate_session_secret!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigSessionSecretError,
            "Session secret is not set."
          )
        end

        it "raises ConfigSessionSecretError for blank string" do
          config.session_secret = "   "
          expect {
            described_class.send(:validate_session_secret!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigSessionSecretError,
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
            Securial::Config::Errors::ConfigSessionSecretError,
            "Session secret must be a String."
          )
        end

        it "raises ConfigSessionSecretError for Array" do
          config.session_secret = ["secret"]
          expect {
            described_class.send(:validate_session_secret!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigSessionSecretError,
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
  end

  describe "Mailer configuration validation" do
    describe ".validate_mailer_sender!" do
      context "when mailer_sender is not set" do
        it "raises ConfigMailerSenderError" do
          config.mailer_sender = nil
          expect {
            described_class.send(:validate_mailer_sender!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigMailerSenderError,
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
            Securial::Config::Errors::ConfigMailerSenderError,
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
            Securial::Config::Errors::ConfigMailerSenderError,
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
  end

  describe "Password configuration validation" do
    describe ".validate_password_config!" do
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

    describe ".validate_password_reset_subject!" do
      context "when password_reset_email_subject is not set" do
        it "raises ConfigPasswordError" do
          config.password_reset_email_subject = nil
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
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
            Securial::Config::Errors::ConfigPasswordError,
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
            Securial::Config::Errors::ConfigPasswordError,
            "Password reset email subject must be a String."
          )
        end

        it "raises ConfigPasswordError for Array" do
          config.password_reset_email_subject = ["Reset Password"]
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
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

    describe ".validate_password_min_max_length!" do
      describe "minimum length for password" do
        context "when password_min_length is not set" do
          it "raises ConfigPasswordError" do
            config.password_min_length = nil
            expect {
              described_class.send(:validate_password_config!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigPasswordError,
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
              Securial::Config::Errors::ConfigPasswordError,
              "Password minimum length must be a positive integer."
            )
          end

          it "raises ConfigPasswordError for Array" do
            config.password_min_length = [8]
            expect {
              described_class.send(:validate_password_config!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigPasswordError,
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
              Securial::Config::Errors::ConfigPasswordError,
              "Password minimum length must be a positive integer."
            )
          end

          it "raises ConfigPasswordError for negative value" do
            config.password_min_length = -1
            expect {
              described_class.send(:validate_password_config!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigPasswordError,
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
              Securial::Config::Errors::ConfigPasswordError,
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
              Securial::Config::Errors::ConfigPasswordError,
              "Password maximum length must be an integer greater than or equal to the minimum length."
            )
          end

          it "raises ConfigPasswordError for Array" do
            config.password_max_length = [20]
            expect {
              described_class.send(:validate_password_config!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigPasswordError,
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
              Securial::Config::Errors::ConfigPasswordError,
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

    describe ".validate_password_complexity!" do
      context "when password_complexity is not set" do
        it "raises ConfigPasswordError" do
          config.password_complexity = nil
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
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
            Securial::Config::Errors::ConfigPasswordError,
            "Password complexity regex is not set or is not a valid Regexp."
          )
        end

        it "raises ConfigPasswordError for Integer" do
          config.password_complexity = 12345
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
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

    describe ".validate_password_expiration!" do
      context "when password_expires is not set" do
        it "raises ConfigPasswordError" do
          config.password_expires = nil
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
            "Password expiration must be a boolean value."
          )
        end
      end

      context "when password_expires is not a boolean" do
        it "raises ConfigPasswordError for String" do
          config.password_expires = "true"
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
            "Password expiration must be a boolean value."
          )
        end

        it "raises ConfigPasswordError for Integer" do
          config.password_expires = 1
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
            "Password expiration must be a boolean value."
          )
        end
      end

      context "when password_expires is false and password_expires_in is not set" do
        it "does not raise error" do
          config.password_expires = false
          config.password_expires_in = nil
          expect {
            described_class.send(:validate_password_config!, config)
          }.not_to raise_error
        end
      end

      context "when password_expires_in is not set" do
        it "raises ConfigPasswordError" do
          config.password_expires_in = nil
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
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
            Securial::Config::Errors::ConfigPasswordError,
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
            Securial::Config::Errors::ConfigPasswordError,
            "Password expiration duration is not set or is not a valid ActiveSupport::Duration."
          )
        end

        it "raises ConfigPasswordError for negative duration" do
          config.password_expires_in = -1.hour
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
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

    describe ".validate_password_reset_token!" do
      context "when reset_password_token_secret is not set" do
        it "raises ConfigPasswordError" do
          config.reset_password_token_secret = nil
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
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
            Securial::Config::Errors::ConfigPasswordError,
            "Reset password token secret must be a String."
          )
        end

        it "raises ConfigPasswordError for Array" do
          config.reset_password_token_secret = ["secret"]
          expect {
            described_class.send(:validate_password_config!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigPasswordError,
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
  end

  describe "Response configuration validation" do
    describe ".validate_response_config!" do
      it "validates all response configuration settings" do
        allow(described_class).to receive(:validate_timestamps_in_response!)
        allow(described_class).to receive(:validate_response_keys_format!)

        described_class.send(:validate_response_config!, config)

        expect(described_class).to have_received(:validate_timestamps_in_response!).with(config)
        expect(described_class).to have_received(:validate_response_keys_format!).with(config)
      end
    end

    describe ".validate_response_keys_format!" do
      context "when response_keys_format is invalid" do
        it "raises ConfigResponseKeysFormatError for nil value" do
          config.response_keys_format = nil
          expect {
            described_class.send(:validate_response_keys_format!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigResponseError,
            "Invalid response_keys_format option. Valid options are: :snake_case, :lowerCamelCase, :UpperCamelCase."
          )
        end

        it "raises ConfigResponseKeysFormatError for invalid values" do
          invalid_formats = [:invalid_format, :another_invalid]
          invalid_formats.each do |format|
            config.response_keys_format = format
            expect {
              described_class.send(:validate_response_keys_format!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigResponseError,
              "Invalid response_keys_format option. Valid options are: :snake_case, :lowerCamelCase, :UpperCamelCase."
            )
          end
        end
      end

      context "when response_keys_format is valid" do
        it "does not raise error for valid formats" do
          valid_formats = [:snake_case, :lowerCamelCase, :UpperCamelCase]
          valid_formats.each do |format|
            config.response_keys_format = format
            expect {
              described_class.send(:validate_response_keys_format!, config)
            }.not_to raise_error
          end
        end
      end
    end

    describe ".validate_timestamps_in_response!" do
      context "when timestamps_in_response is invalid" do
        it "raises ConfigTimestampsInResponseError for nil value" do
          config.timestamps_in_response = nil
          expect {
            described_class.send(:validate_timestamps_in_response!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigResponseError,
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
              Securial::Config::Errors::ConfigResponseError,
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

  describe "Security configuration validation" do
    describe ".validate_security_config!" do
      it "validates all security configuration settings" do
        allow(described_class).to receive(:validate_security_headers!)
        allow(described_class).to receive(:validate_rate_limiting!)

        described_class.send(:validate_security_config!, config)

        expect(described_class).to have_received(:validate_security_headers!).with(config)
        expect(described_class).to have_received(:validate_rate_limiting!).with(config)
      end
    end

    describe ".validate_security_headers!" do
      context "when security_headers is invalid" do
        it "raises ConfigSecurityError for nil value" do
          config.security_headers = nil
          expect {
            described_class.send(:validate_security_headers!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigSecurityError,
            "Invalid security_headers option. Valid options are: :strict, :default, :none."
          )
        end

        it "raises ConfigSecurityError for invalid values" do
          invalid_headers = [:invalid_header, :another_invalid]
          invalid_headers.each do |header|
            config.security_headers = header
            expect {
              described_class.send(:validate_security_headers!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "Invalid security_headers option. Valid options are: :strict, :default, :none."
            )
          end
        end
      end

      context "when security_headers is valid" do
        it "does not raise error for valid headers" do
          valid_headers = [:strict, :default, :none]
          valid_headers.each do |header|
            config.security_headers = header
            expect {
              described_class.send(:validate_security_headers!, config)
            }.not_to raise_error
          end
        end
      end
    end

    describe ".validate_rate_limiting!" do
      # Implementation of rate limiting validation will be added here.
      context "when enable_rate_limiting is not set" do
        it "raises ConfigSecurityError for nil value" do
          config.enable_rate_limiting = nil
          expect {
            described_class.send(:validate_rate_limiting!, config)
          }.to raise_error(
            Securial::Config::Errors::ConfigSecurityError,
            "enable_rate_limiting must be a boolean value."
          )
        end

        context "when enable_rate_limiting is not a boolean" do
          it "raises ConfigSecurityError for String" do
            config.enable_rate_limiting = "true"
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "enable_rate_limiting must be a boolean value."
            )
          end

          it "raises ConfigSecurityError for Integer" do
            config.enable_rate_limiting = 1
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "enable_rate_limiting must be a boolean value."
            )
          end
        end

        context "when enable_rate_limiting is true" do
          context "when rate_limit_requests_per_minute is not set" do
            it "raises ConfigSecurityError" do
              config.enable_rate_limiting = true
              config.rate_limit_requests_per_minute = nil
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
              )
            end
          end

          context "when rate_limit_requests_per_minute is not an Integer" do
            it "raises ConfigSecurityError for String" do
              config.rate_limit_requests_per_minute = "60"
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
              )
            end

            it "raises ConfigSecurityError for Array" do
              config.rate_limit_requests_per_minute = [60]
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::
  ConfigSecurityError,
                "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
              )
            end
          end

          context "when rate_limit_requests_per_minute is less than or equal to 0" do
            it "raises ConfigSecurityError for 0" do
              config.rate_limit_requests_per_minute = 0
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
              )
            end

            it "raises ConfigSecurityError for negative value" do
              config.rate_limit_requests_per_minute = -10
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
              )
            end
          end

          context "when rate_limit_requests_per_minute is valid" do
            it "does not raise error for valid values" do
              valid_limits = [10, 30, 60, 100]
              valid_limits.each do |limit|
                config.rate_limit_requests_per_minute = limit
                expect {
                  described_class.send(:validate_rate_limiting!, config)
                }.not_to raise_error
              end
            end
          end

          context "when rate_limit_response_status is not set" do
            it "raises ConfigSecurityError" do
              config.rate_limit_response_status = nil
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_response_status must be an HTTP status code between 4xx and 5xx."
              )
            end
          end

          context "when rate_limit_response_status is not an Integer" do
            it "raises ConfigSecurityError for String" do
              config.rate_limit_response_status = "429"
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_response_status must be an HTTP status code between 4xx and 5xx."
              )
            end

            it "raises ConfigSecurityError for Array" do
              config.rate_limit_response_status = [429]
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_response_status must be an HTTP status code between 4xx and 5xx."
              )
            end
          end

          context "when rate_limit_response_status is not a valid HTTP status code" do
            it "raises ConfigSecurityError" do
              config.rate_limit_response_status = 200
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_response_status must be an HTTP status code between 4xx and 5xx."
              )
            end
          end

          context "when rate_limit_response_status is valid" do
            it "does not raise error for valid status codes" do
              valid_statuses = [429, 503]
              valid_statuses.each do |status|
                config.rate_limit_response_status = status
                expect {
                  described_class.send(:validate_rate_limiting!, config)
                }.not_to raise_error
              end
            end
          end

          context "when rate_limit_response_message is not set" do
            it "raises ConfigSecurityError" do
              config.rate_limit_response_message = nil
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_response_message must be a non-empty String."
              )
            end
          end

          context "when rate_limit_response_message is blank" do
            it "raises ConfigSecurityError" do
              config.rate_limit_response_message = ""
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.to raise_error(
                Securial::Config::Errors::ConfigSecurityError,
                "rate_limit_response_message must be a non-empty String."
              )
            end
          end

          context "when rate_limit_response_message is not a String" do
          it "raises ConfigSecurityError for Integer" do
            config.rate_limit_response_message = 12345
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "rate_limit_response_message must be a non-empty String."
            )
          end

          it "raises ConfigSecurityError for Array" do
            config.rate_limit_response_message = ["Too many requests"]
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "rate_limit_response_message must be a non-empty String."
            )
          end
          end

          context "when all rate limiting settings are valid" do
            it "does not raise error for valid settings" do
              config.enable_rate_limiting = true
              config.rate_limit_requests_per_minute = 60
              config.rate_limit_response_status = 429
              config.rate_limit_response_message = "Too many requests, please try again later."
              expect {
                described_class.send(:validate_rate_limiting!, config)
              }.not_to raise_error
            end
          end
        end

        context "when enable_rate_limiting is false" do
          it "does not raise error for any rate limiting settings" do
            config.enable_rate_limiting = false
            config.rate_limit_requests_per_minute = nil
            config.rate_limit_response_status = nil
            config.rate_limit_response_message = nil
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.not_to raise_error
          end

          it "does not raise error even if other rate limiting settings are set" do
            config.enable_rate_limiting = false
            config.rate_limit_requests_per_minute = 60
            config.rate_limit_response_status = 429
            config.rate_limit_response_message = "Too many requests, please try again later."
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.not_to raise_error
          end
        end

        context "when enable_rate_limiting is true but rate limiting settings are not set" do
          it "raises ConfigSecurityError for missing rate limit settings" do
            config.enable_rate_limiting = true
            config.rate_limit_requests_per_minute = nil
            config.rate_limit_response_status = nil
            config.rate_limit_response_message = nil
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
            )
          end
        end

        context "when enable_rate_limiting is true but rate_limit_requests_per_minute is not set" do
          it "raises ConfigSecurityError for missing rate limit requests per minute" do
            config.enable_rate_limiting = true
            config.rate_limit_requests_per_minute = nil
            config.rate_limit_response_status = 429
            config.rate_limit_response_message = "Too many requests, please try again later."
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
            )
          end
        end

        context "when enable_rate_limiting is true but rate_limit_response_status is not set" do
          it "raises ConfigSecurityError for missing rate limit response status" do
            config.enable_rate_limiting = true
            config.rate_limit_requests_per_minute = 60
            config.rate_limit_response_status = nil
            config.rate_limit_response_message = "Too many requests, please try again later."
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "rate_limit_response_status must be an HTTP status code between 4xx and 5xx."
            )
          end
        end

        context "when enable_rate_limiting is true but rate_limit_response_message is not set" do
          it "raises ConfigSecurityError for missing rate limit response message" do
            config.enable_rate_limiting = true
            config.rate_limit_requests_per_minute = 60
            config.rate_limit_response_status = 429
            config.rate_limit_response_message = nil
            expect {
              described_class.send(:validate_rate_limiting!, config)
            }.to raise_error(
              Securial::Config::Errors::ConfigSecurityError,
              "rate_limit_response_message must be a non-empty String."
            )
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
