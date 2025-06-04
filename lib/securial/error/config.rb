module Securial
  module Error
    module Config
      class InvalidConfigurationError < Securial::Error::BaseError
        default_message "Invalid configuration for Securial"
      end

      class LoggerValidationError < InvalidConfigurationError
        default_message "Logger configuration validation failed"
      end

      class RolesValidationError < InvalidConfigurationError
        default_message "Roles configuration validation failed"
      end

      class SessionValidationError < InvalidConfigurationError
        default_message "Session configuration validation failed"
      end

      class MailerValidationError < InvalidConfigurationError
        default_message "Mailer configuration validation failed"
      end

      class PasswordValidationError < InvalidConfigurationError
        default_message "Password configuration validation failed"
      end

      class ResponseValidationError < InvalidConfigurationError
        default_message "Response configuration validation failed"
      end

      class SecurityValidationError < InvalidConfigurationError
        default_message "Security configuration validation failed"
      end
    end
  end
end
