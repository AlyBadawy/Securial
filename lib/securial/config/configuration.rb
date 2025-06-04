require "securial/config/validation"
require "securial/helpers/regex_helper"

module Securial
  module Config
    class Configuration
      def self.default_config_attributes # rubocop:disable Metrics/MethodLength
        {
          # Logger configuration
          log_to_file: !Rails.env.test?,
          log_to_stdout: !Rails.env.test?,
          log_file_level: :debug,
          log_stdout_level: :debug,

          # Roles configuration
          admin_role: :admin,

          session_expiration_duration: 3.minutes,
          session_secret: "secret",
          session_algorithm: :hs256,
          session_refresh_token_expires_in: 1.week,

          # Mailer configuration
          mailer_sender: "no-reply@example.com",

          # Password configuration
          password_reset_email_subject: "SECURIAL: Password Reset Instructions",
          password_min_length: 8,
          password_max_length: 128,
          password_complexity: Securial::Helpers::RegexHelper::PASSWORD_REGEX,
          password_expires: true,
          password_expires_in: 90.days,
          reset_password_token_expires_in: 2.hours,
          reset_password_token_secret: "reset_secret",

          # Response configuration
          response_keys_format: :snake_case,
          timestamps_in_response: :all,

          # Security configuration
          security_headers: :strict,
          rate_limiting_enabled: true,
          rate_limit_requests_per_minute: 60,
          rate_limit_response_status: 429,
          rate_limit_response_message: "Too many requests, please try again later.",
        }
      end

      def initialize
        self.class.default_config_attributes.each do |attr, default_value|
          instance_variable_set("@#{attr}", default_value)
        end
      end

      default_config_attributes.each_key do |attr|
        define_method(attr) { instance_variable_get("@#{attr}") }

        define_method("#{attr}=") do |value|
          instance_variable_set("@#{attr}", value)
          validate!
        end
      end

      private

      def validate!
        Securial::Config::Validation.validate_all!(self)
      end
    end
  end
end
