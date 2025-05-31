require "logger"
require "active_support/logger"
require "active_support/tagged_logging"

module Securial
  class Logger
    COLORS = {
      "DEBUG" => "\e[36m",   # cyan
      "INFO" => "\e[32m",   # green
      "WARN" => "\e[33m",   # yellow
      "ERROR" => "\e[31m",   # red
      "FATAL" => "\e[35m",   # magenta
      "UNKNOWN" => "\e[37m",   # white
    }.freeze
    CLEAR = "\e[0m"
    SEVERITY_WIDTH = 5

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

      # Re-apply colorized formatter at the wrapper level if STDOUT is present and not in test.
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

    class Broadcaster
      def initialize(*targets)
        @targets = targets
      end

      ::Logger::Severity.constants.each do |severity|
        method = severity.downcase
        define_method(method) do |*args, &block|
          @targets.each do |logger|
            if logger.level <= ::Logger::Severity.const_get(severity)
              logger.send(method, *args, &block)
            end
          end
        end
      end

      def add(severity, message = nil, progname = nil, &block)
        @targets.each do |logger|
          if logger.level <= severity.to_i
            logger.add(severity, message, progname, &block)
          end
        end
      end

      def <<(msg)
        @targets.each { |logger| logger << msg }
      end

      def close
        @targets.each { |logger| logger.close if logger.respond_to?(:close) }
      end

      def flush
        @targets.each { |logger| logger.flush if logger.respond_to?(:flush) }
      end

      def formatter
        @targets.first.formatter if @targets.any?
      end

      def formatter=(formatter)
        @targets.each { |logger| logger.formatter = formatter }
      end
    end
  end
end
