require "logger"
require "active_support/logger"
require "active_support/tagged_logging"
require_relative "colors"
require_relative "broadcaster"

module Securial
  module Logger
    def self.build # rubocop:disable Metrics/MethodLength
      loggers = []
      colorize_stdout = false

      unless Securial.configuration.log_to_file == false
        file_logger = ::Logger.new(Rails.root.join("log", "securial.log"))
        file_logger.level = resolve_level(Securial.configuration.log_file_level)
        file_logger.formatter = ::Logger::Formatter.new
        loggers << file_logger
      end

      unless Securial.configuration.log_to_stdout == false
        stdout_logger = ::Logger.new(STDOUT)
        stdout_logger.level = resolve_level(Securial.configuration.log_stdout_level)
        stdout_logger.formatter = proc do |severity, timestamp, progname, msg|
          color = COLORS[severity] || CLEAR
          padded = severity.ljust(SEVERITY_WIDTH)
          formatted = "#{timestamp.strftime("%Y-%m-%d %H:%M:%S")} #{padded} -- : #{msg}\n"
          "#{color}#{formatted}#{CLEAR}"
        end
        colorize_stdout = true
        loggers << stdout_logger
      end

      if loggers.empty?
        null_logger = ::Logger.new(IO::NULL)
        return ActiveSupport::TaggedLogging.new(null_logger)
      end

      broadcaster = Broadcaster.new(*loggers)
      tagged_logger = ActiveSupport::TaggedLogging.new(broadcaster)

      if colorize_stdout && !Rails.env.test?
        tagged_logger.formatter = proc do |severity, timestamp, progname, msg|
          color = COLORS[severity] || CLEAR
          padded = severity.ljust(SEVERITY_WIDTH)
          formatted = "#{timestamp.strftime("%Y-%m-%d %H:%M:%S")} #{padded} -- : #{msg}\n"
          "#{color}#{formatted}#{CLEAR}"
        end
      end

      tagged_logger
    end

    def self.resolve_level(level)
      return ::Logger::INFO if level.nil?
      ::Logger.const_get(level.to_s.upcase)
    rescue NameError
      ::Logger::INFO
    end
  end
end
