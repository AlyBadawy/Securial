require_relative "../helpers/_index"
module Securial
  module Config
    VALID_SESSION_ENCRYPTION_ALGORITHMS = [:hs256, :hs384, :hs512].freeze
    VALID_TIMESTAMP_OPTIONS = [:all, :admins_only, :none].freeze
    VALID_RESPONSE_KEYS_FORMATS = [:snake_case, :lowerCamelCase, :UpperCamelCase].freeze

    class Configuration
      def self.config_attributes # rubocop:disable Metrics/MethodLength
        {
          log_to_file: !Rails.env.test?,
          log_to_stdout: !Rails.env.test?,
          log_file_level: :info,
          log_stdout_level: :info,
          admin_role: :admin,
          session_expiration_duration: 3.minutes,
          session_secret: "secret",
          session_algorithm: :hs256,
          mailer_sender: "no-reply@example.com",
          password_reset_email_subject: "SECURIAL: Password Reset Instructions",
          password_min_length: 8,
          password_max_length: 128,
          password_complexity: Securial::RegexHelper::PASSWORD_REGEX,
          password_expires: true,
          password_expires_in: 90.days,
          reset_password_token_expires_in: 2.hours,
          reset_password_token_secret: "reset_secret",
          timestamps_in_response: :all,
          response_keys_format: :snake_case,
        }
      end

      def initialize
        self.class.config_attributes.each do |attr, default|
          instance_variable_set("@#{attr}", default)
        end
        validate!
      end

      config_attributes.each_key do |attr|
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
