# @title Securial Logger Configuration
#
# Defines the logging interface for the Securial framework.
#
# This file establishes the logging system for Securial, providing methods
# to access and configure the application's logger instance. By default,
# it initializes a logger using the Securial::Logger::Builder class, which
# configures appropriate log levels and formatters based on the current environment.
#
# @example Basic logging usage
#   # Log messages at different levels
#   Securial.logger.debug("Detailed debugging information")
#   Securial.logger.info("General information about system operation")
#   Securial.logger.warn("Warning about potential issue")
#   Securial.logger.error("Error condition")
#
# @example Setting a custom logger
#   # Configure a custom logger
#   custom_logger = Logger.new(STDOUT)
#   custom_logger.level = :info
#   Securial.logger = custom_logger
#
require_relative "logger/builder"

module Securial
  extend self
  attr_accessor :logger

  # Returns the logger instance used by Securial.
  #
  # If no logger has been set, initializes a new logger instance using
  # the Securial::Logger::Builder class, which configures the logger
  # based on the current environment settings.
  #
  # @return [Securial::Logger::Builder] the configured logger instance
  # @see Securial::Logger::Builder
  def logger
    @logger ||= Securial::Logger::Builder.build
  end

  # Sets the logger instance for Securial.
  #
  # This allows applications to provide their own custom logger
  # implementation that may have specialized formatting or output
  # destinations.
  #
  # @param logger [Logger] a Logger-compatible object that responds to standard
  #   logging methods (debug, info, warn, error, fatal)
  # @return [Logger] the newly set logger instance
  # @example
  #   Securial.logger = Rails.logger
  def logger=(logger)
    @logger = logger
  end
end
