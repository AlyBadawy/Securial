require "logger"
require "active_support/logger"
require "active_support/tagged_logging"

module Securial
  class Logger
    def self.build
      outputs = []

      unless Securial.configuration.log_to_file == false
        log_file = Rails.root.join("log", "securial.log").open("a")
        log_file.sync = true
        outputs << log_file
      end

      unless Securial.configuration.log_to_stdout == false
        outputs << STDOUT
      end

      if outputs.empty?
        null_logger = ::Logger.new(IO::NULL)
        return ActiveSupport::TaggedLogging.new(null_logger)
      end

      logger = ActiveSupport::Logger.new(MultiIO.new(*outputs))
      logger.level = resolve_log_level
      logger.formatter = ::Logger::Formatter.new

      ActiveSupport::TaggedLogging.new(logger)
    end

    def self.resolve_log_level
      file_level = Securial.configuration.log_file_level
      stdout_level = Securial.configuration.log_stdout_level

      # Use the lower (more verbose) level of the two
      levels = [file_level, stdout_level].compact.map do |lvl|
        begin
          ::Logger.const_get(lvl.to_s.upcase)
        rescue NameError
          nil
        end
      end.compact

      levels.min || ::Logger::INFO
    end

    private

    class MultiIO
      def initialize(*targets)
        @targets = targets
      end

      def write(*args)
        @targets.each { |t| t.write(*args) }
      end

      def close
        @targets.each do |t|
          next if [STDOUT, STDERR].include?(t)
          t.close
        end
      end

      def flush
        @targets.each { |t| t.flush if t.respond_to?(:flush) }
      end
    end
  end
end
