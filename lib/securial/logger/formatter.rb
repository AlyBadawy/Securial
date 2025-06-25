# @title Securial Logger Formatters
#
# Log formatting utilities for the Securial framework's logging system.
#
# This file defines formatter classes that determine how log messages are displayed,
# providing both colorful terminal-friendly output and plain text output options.
# These formatters are used by the Securial::Logger system to ensure consistent
# and readable log formats across different environments.
#
# @example Using a formatter with a standard Ruby logger
#   require 'logger'
#   logger = Logger.new(STDOUT)
#   logger.formatter = Securial::Logger::Formatter::ColorfulFormatter.new
#
#   logger.info("Application started")
#   # Output: [2023-11-15 14:30:22] INFO  -- Application started (in green color)
#
module Securial
  module Logger
    # Formatting utilities for Securial's logging system.
    #
    # This module contains formatter classes and constants that determine
    # how log messages are presented. It provides both colored output for
    # terminal environments and plain text output for file logging.
    #
    module Formatter
      # Terminal color codes for different log severity levels.
      #
      # @return [Hash{String => String}] Mapping of severity names to ANSI color codes
      #
      COLORS = {
        "DEBUG" => "\e[36m",   # cyan
        "INFO" => "\e[32m",    # green
        "WARN" => "\e[33m",    # yellow
        "ERROR" => "\e[31m",   # red
        "FATAL" => "\e[35m",   # magenta
        "UNKNOWN" => "\e[37m", # white
      }.freeze

      # ANSI code to reset terminal colors.
      #
      # @return [String] Terminal color reset sequence
      #
      CLEAR = "\e[0m"

      # Width used for severity level padding in log output.
      #
      # @return [Integer] Number of characters to use for severity field
      #
      SEVERITY_WIDTH = 5

      # Formatter that adds color to log output for terminal display.
      #
      # This formatter colorizes log messages based on their severity level,
      # making them easier to distinguish in terminal output. It follows the
      # standard Ruby Logger formatter interface.
      #
      # @example
      #   logger = Logger.new(STDOUT)
      #   logger.formatter = Securial::Logger::Formatter::ColorfulFormatter.new
      #
      class ColorfulFormatter
        # Formats a log message with color based on severity.
        #
        # @param severity [String] Log severity level (DEBUG, INFO, etc.)
        # @param timestamp [Time] Time when the log event occurred
        # @param progname [String] Program name or context for the log message
        # @param msg [String] The log message itself
        # @return [String] Formatted log message with appropriate ANSI color codes
        #
        def call(severity, timestamp, progname, msg)
          color = COLORS[severity] || CLEAR
          padded_severity = severity.ljust(SEVERITY_WIDTH)
          formatted = "[#{progname}][#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}] #{padded_severity} -- #{msg}\n"

          "#{color}#{formatted}#{CLEAR}"
        end
      end

      # Formatter that produces plain text log output without colors.
      #
      # This formatter is suitable for file logging or environments where
      # terminal colors are not supported. It follows the standard Ruby
      # Logger formatter interface.
      #
      # @example
      #   logger = Logger.new('application.log')
      #   logger.formatter = Securial::Logger::Formatter::PlainFormatter.new
      #
      class PlainFormatter
        # Formats a log message in plain text without color codes.
        #
        # @param severity [String] Log severity level (DEBUG, INFO, etc.)
        # @param timestamp [Time] Time when the log event occurred
        # @param progname [String] Program name or context for the log message
        # @param msg [String] The log message itself
        # @return [String] Formatted log message as plain text
        #
        def call(severity, timestamp, progname, msg)
          padded_severity = severity.ljust(SEVERITY_WIDTH)
          formatted = "[#{timestamp.strftime("%Y-%m-%d %H:%M:%S")}] #{padded_severity} -- #{msg}\n"

          formatted
        end
      end
    end
  end
end
