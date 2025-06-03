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

        file_logger = ::Logger.new(Rails.root.join("log", "securial.log"))
        file_logger.progname = progname
        file_logger.formatter = Formatter::PlainFormatter.new
        tagged_file_logger = ActiveSupport::TaggedLogging.new(file_logger)
        loggers << tagged_file_logger

        stdout_logger = ::Logger.new($stdout)
        stdout_logger.progname = progname
        stdout_logger.formatter = Formatter::ColorfulFormatter.new
        tagged_stdout_logger = ActiveSupport::TaggedLogging.new(stdout_logger)
        loggers << tagged_stdout_logger

        Broadcaster.new(loggers)
      end
    end
  end
end
