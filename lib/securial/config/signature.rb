module Securial
  module Config
    module Signature
      LOG_LEVELS         = %i[debug info warn error fatal unknown].freeze
      SESSION_ALGORITHMS = %i[hs256 hs384 hs512].freeze
      SECURITY_HEADERS   = %i[strict default none].freeze
      TIMESTAMP_OPTIONS  = %i[all admins_only none].freeze
      RESPONSE_KEYS_FORMATS = %i[snake_case lowerCamelCase UpperCamelCase].freeze

      extend self

      def config_signature
        [
          general_signature,
          logger_signature,
          roles_signature,
          session_signature,
          mailer_signature,
          password_signature,
          response_signature,
          security_signature,
        ].reduce({}, :merge)
      end

      def default_config_attributes
        config_signature.transform_values do |options|
          options[:default]
        end
      end

      private

      def general_signature
        {
          app_name: { type: String, required: true, default: "Securial" },
        }
      end

      def logger_signature
        {
          log_to_file: { type: [TrueClass, FalseClass], required: true, default: Rails.env.test? ? false : true },
          log_file_level: { type: Symbol, required: "log_to_file", allowed_values: LOG_LEVELS, default: :debug },
          log_to_stdout: { type: [TrueClass, FalseClass], required: true, default: Rails.env.test? ? false : true },
          log_stdout_level: { type: Symbol, required: "log_to_stdout", allowed_values: LOG_LEVELS, default: :debug },
        }
      end

      def roles_signature
        {
          admin_role: { type: String, required: true, default: "admin" },
        }
      end

      def session_signature
        {
          session_expiration_duration: { type: ActiveSupport::Duration, required: true, default: 3.minutes },
          session_secret: { type: String, required: true, default: "secret" },
          session_algorithm: { type: Symbol, required: true, allowed_values: SESSION_ALGORITHMS, default: :hs256 },
          session_refresh_token_expires_in: { type: ActiveSupport::Duration, required: true, default: 1.week },
        }
      end

      def mailer_signature
        {
          mailer_sender: { type: String, required: true, default: "no-reply@example.com" },
          mailer_sign_up_enabled: { type: [TrueClass, FalseClass], required: true, default: true },
          mailer_sign_up_subject: { type: String, required: "mailer_sign_up_enabled", default: "SECURIAL: Welcome to Our Service" },
          mailer_sign_in_enabled: { type: [TrueClass, FalseClass], required: true, default: true },
          mailer_sign_in_subject: { type: String, required: "mailer_sign_in_enabled", default: "SECURIAL: Sign In Notification" },
          mailer_update_account_enabled: { type: [TrueClass, FalseClass], required: true, default: true },
          mailer_update_account_subject: { type: String, required: "mailer_update_account_enabled", default: "SECURIAL: Account Update Notification" },
          mailer_forgot_password_subject: { type: String, required: true, default: "SECURIAL: Password Reset Instructions" },
        }
      end

      def password_signature
        {
          password_min_length: { type: Numeric, required: true, default: 8 },
          password_max_length: { type: Numeric, required: true, default: 128 },
          password_complexity: { type: Regexp, required: true, default: Securial::Helpers::RegexHelper::PASSWORD_REGEX },
          password_expires: { type: [TrueClass, FalseClass], required: true, default: true },
          password_expires_in: { type: ActiveSupport::Duration, required: "password_expires", default: 90.days },
          reset_password_token_expires_in: { type: ActiveSupport::Duration, required: true, default: 2.hours },
          reset_password_token_secret: { type: String, required: true, default: "reset_secret" },
        }
      end

      def response_signature
        {
          response_keys_format: { type: Symbol, required: true, allowed_values:
            RESPONSE_KEYS_FORMATS, default: :snake_case, },
          timestamps_in_response: { type: Symbol, required: true, allowed_values: TIMESTAMP_OPTIONS, default: :all },
        }
      end

      def security_signature
        {
          security_headers: { type: Symbol, required: true, allowed_values: SECURITY_HEADERS, default: :strict },
          rate_limiting_enabled: { type: [TrueClass, FalseClass], required: true, default: true },
          rate_limit_requests_per_minute: { type: Numeric, required: "rate_limiting_enabled", default: 60 },
          rate_limit_response_status: { type: Numeric, required: "rate_limiting_enabled", default: 429 },
          rate_limit_response_message: { type: String, required: "rate_limiting_enabled", default: "Too many requests, please try again later." },
        }
      end
    end
  end
end
