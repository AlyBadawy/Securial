require "securial/error"

module Securial
  module Error
    module Config
      class InvalidConfigurationError < Securial::Error::BaseSecurialError
        def initialize(message = nil)
          super(message || "Invalid configuration for Securial")
        end
      end

      class LoggerValidationError < InvalidConfigurationError
        def initialize(message = nil)
          super(message || "Logger configuration validation failed")
        end
      end

      class RolesValidationError < InvalidConfigurationError
        def initialize(message = nil)
          super(message || "Roles configuration validation failed")
        end
      end

      class SessionValidationError < InvalidConfigurationError
        def initialize(message = nil)
          super(message || "Session configuration validation failed")
        end
      end

      class MailerValidationError < InvalidConfigurationError
        def initialize(message = nil)
          super(message || "Mailer configuration validation failed")
        end
      end

      class PasswordValidationError < InvalidConfigurationError
        def initialize(message = nil)
          super(message || "Password configuration validation failed")
        end
      end

      class ResponseValidationError < InvalidConfigurationError
        def initialize(message = nil)
          super(message || "Response configuration validation failed")
        end
      end

      class SecurityValidationError < InvalidConfigurationError
        def initialize(message = nil)
          super(message || "Security configuration validation failed")
        end
      end
    end
  end
end
