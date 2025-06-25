# @title Securial Logger Broadcaster
#
# Logger broadcasting utility for the Securial framework.
#
# This file defines a broadcaster class that sends logging messages to multiple
# destination loggers simultaneously. This enables unified logging across different
# outputs (like console and file) while maintaining appropriate formatting for each.
#
# @example Creating a broadcaster with multiple loggers
#   # Create individual loggers
#   file_logger = Logger.new('application.log')
#   stdout_logger = Logger.new(STDOUT)
#
#   # Combine them into a broadcaster
#   broadcaster = Securial::Logger::Broadcaster.new([file_logger, stdout_logger])
#
#   # Log messages go to both destinations
#   broadcaster.info("Processing authentication request")
#
module Securial
  module Logger
    # Broadcasts log messages to multiple logger instances simultaneously.
    #
    # This class implements the Logger interface and forwards all logging calls
    # to a collection of underlying loggers. This allows unified logging to
    # multiple destinations (e.g., file and stdout) while maintaining specific
    # formatting for each destination.
    #
    # @example Using a broadcaster with two loggers
    #   file_logger = Logger.new('app.log')
    #   console_logger = Logger.new(STDOUT)
    #   broadcaster = Broadcaster.new([file_logger, console_logger])
    #
    #   # This logs to both destinations
    #   broadcaster.info("User logged in")
    #
    class Broadcaster
      # Initializes a new broadcaster with the provided loggers.
      #
      # @param loggers [Array<Logger>] Collection of logger instances
      # @return [Broadcaster] New broadcaster instance
      def initialize(loggers)
        @loggers = loggers
      end

      # Dynamically define logging methods for each severity level
      # (debug, info, warn, error, fatal, unknown)
      ::Logger::Severity.constants.each do |severity|
        define_method(severity.downcase) do |*args, &block|
          @loggers.each { |logger| logger.public_send(severity.downcase, *args, &block) }
        end
      end

      # Writes a message to each underlying logger.
      #
      # @param msg [String] Message to be written
      # @return [Array] Results from each logger's << method
      def <<(msg)
        @loggers.each { |logger| logger << msg }
      end

      # Closes all underlying loggers.
      #
      # @return [void]
      def close
        @loggers.each(&:close)
      end

      # No-op method to satisfy the Logger interface.
      #
      # Since each underlying logger has its own formatter, setting a
      # formatter on the broadcaster is not supported.
      #
      # @param _formatter [Object] Ignored formatter object
      # @return [void]
      def formatter=(_formatter)
        # Do nothing - each logger maintains its own formatter
      end

      # Returns nil to satisfy the Logger interface.
      #
      # Since each underlying logger has its own formatter, there is
      # no single formatter for the broadcaster.
      #
      # @return [nil] Always returns nil
      def formatter
        nil
      end

      # Returns the collection of managed loggers.
      #
      # @return [Array<Logger>] All loggers managed by this broadcaster
      #
      def loggers
        @loggers
      end

      # Executes a block with the specified tags added to the log.
      #
      # Supports ActiveSupport::TaggedLogging by forwarding tagged blocks
      # to all underlying loggers that support tagging.
      #
      # @param tags [Array<String>] Tags to apply to log messages
      # @yield Block to be executed with the tags applied
      # @return [Object] Result of the block
      #
      def tagged(*tags, &block)
        # If all loggers support tagged, nest the calls, otherwise just yield.
        taggable_loggers = @loggers.select { |logger| logger.respond_to?(:tagged) }
        if taggable_loggers.any?
          # Nest tags for all taggable loggers
          taggable_loggers.reverse.inject(block) do |blk, logger|
            proc { logger.tagged(*tags, &blk) }
          end.call
        else
          yield
        end
      end

      # Checks if the broadcaster responds to the given method.
      #
      # @param method [Symbol] Method name to check
      # @param include_private [Boolean] Whether to include private methods
      # @return [Boolean] True if any of the underlying loggers respond to the method
      def respond_to_missing?(method, include_private = false)
        @loggers.any? { |logger| logger.respond_to?(method, include_private) } || super
      end

      # Delegates missing methods to all underlying loggers.
      #
      # If all loggers respond to the method, it will be called on each logger.
      # Otherwise, raises a NoMethodError.
      #
      # @param method [Symbol] Method name to call
      # @param args [Array] Arguments to pass to the method
      # @param block [Proc] Block to pass to the method
      # @return [Array] Results from each logger's method call
      # @raise [NoMethodError] If any logger doesn't respond to the method
      def method_missing(method, *args, &block)
        if @loggers.all? { |logger| logger.respond_to?(method) }
          @loggers.map { |logger| logger.send(method, *args, &block) }
        else
          super
        end
      end
    end
  end
end
