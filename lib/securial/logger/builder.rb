require "logger"
require "active_support/logger"
require "active_support/tagged_logging"

require "securial/logger/broadcaster"
require "securial/logger/formatter"

module Securial
  module Logger
    class Builder
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

      def self.create_file_logger(progname, level, loggers)
        file_logger = ::Logger.new(Rails.root.join("log", "securial-#{Rails.env}.log"))
        file_logger.level = level
        file_logger.progname = progname
        file_logger.formatter = Formatter::PlainFormatter.new
        tagged_file_logger = ActiveSupport::TaggedLogging.new(file_logger)
        loggers << tagged_file_logger
      end

      def self.create_stdout_logger(progname, level, loggers)
        stdout_logger = ::Logger.new($stdout)
        stdout_logger.level = level
        stdout_logger.progname = progname
        stdout_logger.formatter = Formatter::ColorfulFormatter.new
        tagged_stdout_logger =  ActiveSupport::TaggedLogging.new(stdout_logger)
        loggers << tagged_stdout_logger
      end
    end
  end
end
