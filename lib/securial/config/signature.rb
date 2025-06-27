# @title Securial Configuration Signature
#
# Configuration schema definition and validation rules for the Securial framework.
#
# This module defines the complete configuration schema for Securial, including
# all available configuration options, their types, default values, and validation
# rules. It serves as the single source of truth for what configuration options
# are available and how they should be validated.
#
# @example Getting the complete configuration schema
#   schema = Securial::Config::Signature.config_signature
#   # => { app_name: { type: String, required: true, default: "Securial" }, ... }
#
# @example Getting default configuration values
#   defaults = Securial::Config::Signature.default_config_attributes
#   # => { app_name: "Securial", log_to_file: true, ... }
#
module Securial
  module Config
    # Configuration schema definition and validation rules.
    #
    # This module provides the complete schema for Securial's configuration system,
    # defining all available options, their types, validation rules, and default values.
    # It's used by the configuration system to validate user-provided settings.
    #
    module Signature
      # Valid log levels for the logging system.
      #
      # @return [Array<Symbol>] Available log levels from least to most severe
      #
      LOG_LEVELS = %i[debug info warn error fatal unknown].freeze

      # Supported JWT signing algorithms for session tokens.
      #
      # @return [Array<Symbol>] HMAC algorithms supported for JWT signing
      #
      SESSION_ALGORITHMS = %i[hs256 hs384 hs512].freeze

      # Security header configuration options.
      #
      # @return [Array<Symbol>] Available security header policies
      #
      SECURITY_HEADERS = %i[strict default none].freeze

      # Timestamp inclusion options for API responses.
      #
      # @return [Array<Symbol>] Who should see timestamps in responses
      #
      TIMESTAMP_OPTIONS = %i[all admins_only none].freeze

      # Available key format transformations for API responses.
      #
      # @return [Array<Symbol>] Supported key case formats
      #
      RESPONSE_KEYS_FORMATS = %i[snake_case lowerCamelCase UpperCamelCase].freeze

      extend self

      # Returns the complete configuration schema for Securial.
      #
      # Combines all configuration sections into a single schema hash that defines
      # every available configuration option, its type, validation rules, and
      # default value.
      #
      # @return [Hash] Complete configuration schema with validation rules
      #
      # @example
      #   schema = config_signature
      #   app_name_config = schema[:app_name]
      #   # => { type: String, required: true, default: "Securial" }
      #
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

      # Extracts default values from the configuration schema.
      #
      # Transforms the complete configuration schema to return only the default
      # values for each configuration option, suitable for initializing a new
      # configuration instance.
      #
      # @return [Hash] Default values for all configuration options
      #
      # @example
      #   defaults = default_config_attributes
      #   # => { app_name: "Securial", session_expiration_duration: 3.minutes, ... }
      #
      def default_config_attributes
        config_signature.transform_values do |options|
          options[:default]
        end
      end

      private

      # General application configuration options.
      #
      # @return [Hash] Schema for general application settings
      # @api private
      #
      def general_signature
        {
          app_name: { type: String, required: true, default: "Securial" },
        }
      end

      # Logging system configuration options.
      #
      # @return [Hash] Schema for logging configuration
      # @api private
      #
      def logger_signature
        {
          log_to_file: { type: [TrueClass, FalseClass], required: true, default: Rails.env.test? ? false : true },
          log_file_level: { type: Symbol, required: "log_to_file", allowed_values: LOG_LEVELS, default: :debug },
          log_to_stdout: { type: [TrueClass, FalseClass], required: true, default: Rails.env.test? ? false : true },
          log_stdout_level: { type: Symbol, required: "log_to_stdout", allowed_values: LOG_LEVELS, default: :debug },
        }
      end

      # User role and permission configuration options.
      #
      # @return [Hash] Schema for role management settings
      # @api private
      #
      def roles_signature
        {
          admin_role: { type: Symbol, required: true, default: :admin },
        }
      end

      # Session and JWT token configuration options.
      #
      # @return [Hash] Schema for session management settings
      # @api private
      #
      def session_signature
        {
          session_expiration_duration: { type: ActiveSupport::Duration, required: true, default: 3.minutes },
          session_secret: { type: String, required: true, default: "secret" },
          session_algorithm: { type: Symbol, required: true, allowed_values: SESSION_ALGORITHMS, default: :hs256 },
          session_refresh_token_expires_in: { type: ActiveSupport::Duration, required: true, default: 1.week },
        }
      end

      # Email and notification configuration options.
      #
      # @return [Hash] Schema for mailer settings
      # @api private
      #
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

      # Password policy and security configuration options.
      #
      # @return [Hash] Schema for password management settings
      # @api private
      #
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

      # API response formatting configuration options.
      #
      # @return [Hash] Schema for response formatting settings
      # @api private
      #
      def response_signature
        {
          response_keys_format: { type: Symbol, required: true, allowed_values: RESPONSE_KEYS_FORMATS, default: :snake_case },
          timestamps_in_response: { type: Symbol, required: true, allowed_values: TIMESTAMP_OPTIONS, default: :all },
        }
      end

      # Security and rate limiting configuration options.
      #
      # @return [Hash] Schema for security settings
      # @api private
      #
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
