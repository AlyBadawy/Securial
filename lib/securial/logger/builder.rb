# @title Securial Logger Builder
#
# Logger construction utilities for the Securial framework.
#
# This file defines a builder class that constructs and configures loggers for the Securial
# framework based on application configuration. It supports multiple logging destinations
# (stdout and file) with appropriate formatters for each, and combines them using a
# broadcaster pattern for unified logging.
#
# @example Building a logger with defaults from configuration
#   # Securial.configuration has been set up elsewhere
#   logger = Securial::Logger::Builder.build
#
#   # Log messages go to both configured destinations
#   logger.info("User authentication successful")
#
require "logger"
require "active_support/logger"
require "active_support/tagged_logging"

require "securial/logger/broadcaster"
require "securial/logger/formatter"

module Securial
  module Logger
    # Builder for constructing Securial's logging system.
    #
    # This class provides factory methods to create properly configured logger instances
    # based on the application's configuration settings. It supports multiple logging
    # destinations and handles the setup of formatters, log levels, and tagging.
    #
    class Builder
      # Builds a complete logger system based on configuration settings.
      #
      # Creates file and/or stdout loggers as specified in configuration and
      # combines them using a Broadcaster to provide unified logging to multiple
      # destinations with appropriate formatting for each.
      #
      # @return [Securial::Logger::Broadcaster] A broadcaster containing all configured loggers
      # @see Securial::Logger::Broadcaster
      #
      def self.build
        loggers = []
        progname = "Securial"

        file_logger_enabled = Securial.configuration.log_to_file
        file_logger_level = Securial.configuration.log_file_level
        stdout_logger_enabled = Securial.configuration.log_to_stdout
        stdout_logger_level = Securial.configuration.log_stdout_level

        create_file_logger(progname, file_logger_level, loggers) if file_logger_enabled
        create_stdout_logger(progname, stdout_logger_level, loggers) if stdout_logger_enabled

        Broadcaster.new(loggers)
      end

      # Creates and configures a file logger.
      #
      # Sets up a logger that writes to a Rails environment-specific log file
      # with plain text formatting and adds it to the provided loggers array.
      #
      # @param progname [String] The program name to include in log entries
      # @param level [Integer, Symbol] The log level (e.g., :info, :debug)
      # @param loggers [Array<Logger>] Array to which the new logger will be added
      # @return [ActiveSupport::TaggedLogging] The configured file logger
      # @see Securial::Logger::Formatter::PlainFormatter
      #
      def self.create_file_logger(progname, level, loggers)
        file_logger = ::Logger.new(Rails.root.join("log", "securial-#{Rails.env}.log"))
        file_logger.level = level
        file_logger.progname = progname
        file_logger.formatter = Formatter::PlainFormatter.new
        tagged_file_logger = ActiveSupport::TaggedLogging.new(file_logger)
        loggers << tagged_file_logger
      end

      # Creates and configures a stdout logger.
      #
      # Sets up a logger that writes to standard output with colorful formatting
      # and adds it to the provided loggers array.
      #
      # @param progname [String] The program name to include in log entries
      # @param level [Integer, Symbol] The log level (e.g., :info, :debug)
      # @param loggers [Array<Logger>] Array to which the new logger will be added
      # @return [ActiveSupport::TaggedLogging] The configured stdout logger
      # @see Securial::Logger::Formatter::ColorfulFormatter
      #
      def self.create_stdout_logger(progname, level, loggers)
        stdout_logger = ::Logger.new($stdout)
        stdout_logger.level = level
        stdout_logger.progname = progname
        stdout_logger.formatter = Formatter::ColorfulFormatter.new
        tagged_stdout_logger = ActiveSupport::TaggedLogging.new(stdout_logger)
        loggers << tagged_stdout_logger
      end
    end
  end
end
