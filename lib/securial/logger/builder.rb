require "logger"
require "active_support/logger"
require "active_support/tagged_logging"

require "securial/logger/broadcaster"
require "securial/logger/colors"

module Securial
  module Logger
    class Builder
      def self.build
        loggers = []

        file_logger = ::Logger.new(Rails.root.join("log", "securial.log"))
        file_logger.progname = "Securial"
        loggers << file_logger

        stdout_logger = ::Logger.new($stdout)
        stdout_logger.progname = "Securial"
        stdout_logger.formatter = Colors::Formatter.new
        loggers << stdout_logger

        br = Broadcaster.new(loggers)

        br
      end
    end
  end
end
