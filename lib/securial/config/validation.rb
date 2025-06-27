# @title Securial Configuration Validation
#
# Configuration validation utilities for the Securial framework.
#
# This module provides comprehensive validation for Securial configuration settings,
# ensuring that all required fields are present, types are correct, values are within
# acceptable ranges, and cross-field dependencies are satisfied. It validates against
# the schema defined in Securial::Config::Signature.
#
# @example Validating a configuration object
#   config = Securial::Configuration.new
#   begin
#     Securial::Config::Validation.validate_all!(config)
#   rescue Securial::Error::Config::InvalidConfigurationError => e
#     Rails.logger.error("Configuration error: #{e.message}")
#   end
#
require "securial/logger"

module Securial
  module Config
    # Configuration validation and verification utilities.
    #
    # This module provides methods to validate Securial configuration objects
    # against the defined schema, ensuring type safety, required field presence,
    # and business logic constraints are met before the application starts.
    #
    module Validation
      extend self

      # Validates all configuration settings against the schema.
      #
      # Performs comprehensive validation of the provided configuration object,
      # including required field checks, type validation, value constraints,
      # and cross-field dependency validation.
      #
      # @param [Securial::Configuration] securial_config The configuration object to validate
      # @return [void]
      # @raise [Securial::Error::Config::InvalidConfigurationError] If any validation fails
      #
      # @example
      #   config = Securial::Configuration.new
      #   config.app_name = "MyApp"
      #   config.session_secret = "my-secret-key"
      #
      #   Validation.validate_all!(config)
      #   # Configuration is valid and ready to use
      #
      def validate_all!(securial_config)
        signature = Securial::Config::Signature.config_signature

        validate_required_fields!(signature, securial_config)
        validate_types_and_values!(signature, securial_config)
        validate_password_lengths!(securial_config)
      end

      private

      # Validates that all required configuration fields are present.
      #
      # Checks both unconditionally required fields and conditionally required
      # fields based on other configuration values.
      #
      # @param [Hash] signature The configuration schema from Signature
      # @param [Securial::Configuration] config The configuration object to validate
      # @return [void]
      # @raise [Securial::Error::Config::InvalidConfigurationError] If required fields are missing
      # @api private
      #
      def validate_required_fields!(signature, config)
        signature.each do |key, options|
          value = config.send(key)
          required = options[:required]

          if required == true && value.nil?
            raise_error("#{key} is required but not provided.")
          elsif required.is_a?(String)
            # Handle conditional requirements based on other config values
            dynamic_required = config.send(required)
            signature[key][:required] = dynamic_required
            if dynamic_required && value.nil?
              raise_error("#{key} is required but not provided when #{required} is true.")
            end
          end
        end
      end

      # Validates types and value constraints for configuration fields.
      #
      # Ensures that configuration values match their expected types and fall
      # within acceptable ranges or allowed value sets.
      #
      # @param [Hash] signature The configuration schema from Signature
      # @param [Securial::Configuration] config The configuration object to validate
      # @return [void]
      # @raise [Securial::Error::Config::InvalidConfigurationError] If types or values are invalid
      # @api private
      #
      def validate_types_and_values!(signature, config)
        signature.each do |key, options|
          next unless signature[key][:required]

          value = config.send(key)
          types = Array(options[:type])

          # Type validation
          unless types.any? { |type| value.is_a?(type) }
            raise_error("#{key} must be of type(s) #{types.join(', ')}, but got #{value.class}.")
          end

          # Duration-specific validation
          if options[:type] == ActiveSupport::Duration && value <= 0
            raise_error("#{key} must be a positive duration, but got #{value}.")
          end

          # Numeric value validation
          if options[:type] == Numeric && value < 0
            raise_error("#{key} must be a non-negative numeric value, but got #{value}.")
          end

          # Allowed values validation
          if options[:allowed_values] && options[:allowed_values].exclude?(value)
            raise_error("#{key} must be one of #{options[:allowed_values].join(', ')}, but got #{value}.")
          end
        end
      end

      # Validates password length configuration constraints.
      #
      # Ensures that password minimum length does not exceed maximum length,
      # which would create an impossible constraint for users.
      #
      # @param [Securial::Configuration] config The configuration object to validate
      # @return [void]
      # @raise [Securial::Error::Config::InvalidConfigurationError] If password lengths are invalid
      # @api private
      #
      def validate_password_lengths!(config)
        if config.password_min_length > config.password_max_length
          raise_error("password_min_length cannot be greater than password_max_length.")
        end
      end

      # Logs error message and raises configuration error.
      #
      # Provides a consistent way to handle validation failures by logging
      # the error at fatal level and raising the appropriate exception.
      #
      # @param [String] msg The error message to log and include in the exception
      # @return [void]
      # @raise [Securial::Error::Config::InvalidConfigurationError] Always raises with the provided message
      # @api private
      #
      def raise_error(msg)
        Securial.logger.fatal msg
        raise Securial::Error::Config::InvalidConfigurationError, msg
      end
    end
  end
end
