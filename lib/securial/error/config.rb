module Securial
  module Error
    module Config
      class InvalidConfigurationError < Securial::Error::BaseError
        default_message "Invalid configuration for Securial"
      end
    end
  end
end
