module Securial
  module Error
    class BaseSecurialError < StandardError
      def initialize(message = nil)
        super(message || "An error occurred in Securial")
      end

      def backtrace; []; end
    end

    module Config
      class InvalidConfigurationError < BaseSecurialError
        def initialize(message = nil)
          super(message || "Invalid configuration for Securial")
        end
      end

      class LoggerValidationError < BaseSecurialError
        def initialize(message = nil)
          super(message || "Logger configuration validation failed")
        end
      end
    end
  end
end
