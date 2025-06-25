# @title Securial Configuration Errors
#
# Configuration-related errors for the Securial framework.
#
# This file defines error classes for configuration-related issues in the
# Securial framework, such as missing or invalid configuration options.
# These errors help identify and troubleshoot problems with application setup.
#
module Securial
  module Error
    # Namespace for configuration-related errors in the Securial framework.
    #
    # These errors are raised when the Securial configuration is invalid,
    # missing required values, or contains values that don't meet validation
    # requirements.
    #
    # @example Handling configuration errors
    #   begin
    #     Securial.configure do |config|
    #       # Configure Securial settings
    #     end
    #   rescue Securial::Error::Config::InvalidConfigurationError => e
    #     Rails.logger.error("Securial configuration error: #{e.message}")
    #     # Handle configuration error
    #   end
    #
    module Config
      # Error raised when Securial configuration is invalid.
      #
      # This error is typically raised during application initialization when
      # the provided configuration doesn't meet requirements, such as missing
      # required settings or having values that fail validation.
      #
      # @example Raising a configuration error
      #   raise InvalidConfigurationError, "JWT secret is missing"
      #
      class InvalidConfigurationError < Securial::Error::BaseError
        default_message "Invalid configuration for Securial"
      end
    end
  end
end
