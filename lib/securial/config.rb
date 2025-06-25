# @title Securial Configuration System
#
# Configuration management for the Securial framework.
#
# This file defines the configuration system for Securial, providing mechanisms
# to set, retrieve, and validate configuration options. It uses a conventional
# Ruby configuration block pattern to allow applications to customize Securial's
# behavior through an easy-to-use interface.
#
# @example Basic configuration
#   # In config/initializers/securial.rb
#   Securial.configure do |config|
#     config.jwt_secret = ENV["JWT_SECRET"]
#     config.token_expiry = 2.hours
#     config.refresh_token_expiry = 7.days
#     config.session_timeout = 1.hour
#   end
#
# @example Accessing configuration values
#   # Get the configured token expiry
#   expiry = Securial.configuration.token_expiry
#
require "securial/config/configuration"
require "securial/config/signature"
require "securial/config/validation"

module Securial
  extend self

  # Gets the current configuration instance.
  #
  # Returns the existing configuration or creates a new default configuration
  # if one hasn't been set yet.
  #
  # @return [Securial::Config::Configuration] the current configuration instance
  def configuration
    @configuration ||= Config::Configuration.new
  end

  # Sets the configuration instance.
  #
  # Validates the provided configuration to ensure all required settings
  # are present and have valid values.
  #
  # @param config [Securial::Config::Configuration] the configuration instance to use
  # @raise [ArgumentError] if the provided object is not a Configuration instance
  # @raise [Securial::Error::Config::ValidationError] if the configuration is invalid
  # @return [Securial::Config::Configuration] the newly set configuration
  #
  def configuration=(config)
    if config.is_a?(Config::Configuration)
      @configuration = config
      Securial::Config::Validation.validate_all!(configuration)
    else
      raise ArgumentError, "Expected an instance of Securial::Config::Configuration"
    end
  end

  # Configures the Securial framework using a block.
  #
  # This method provides the conventional Ruby configuration block pattern,
  # yielding the current configuration instance to the provided block for
  # modification. After the block executes, the configuration is validated.
  #
  # @yield [config] Yields the configuration instance to the block
  # @yieldparam config [Securial::Config::Configuration] the configuration instance
  # @raise [Securial::Error::Config::ValidationError] if the configuration is invalid
  # @return [Securial::Config::Configuration] the updated configuration
  def configure
    yield(configuration) if block_given?
    Securial::Config::Validation.validate_all!(configuration)
    configuration
  end
end
