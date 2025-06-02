module Securial
  module Logger
    class Broadcaster
      def initialize(loggers)
        @loggers = loggers
      end

      ::Logger::Severity.constants.each do |severity|
        define_method(severity.downcase) do |*args, &block|
          @loggers.each { |logger| logger.public_send(severity.downcase, *args, &block) }
        end
      end

      def <<(msg)
        @loggers.each { |logger| logger << msg }
      end

      def close
        @loggers.each(&:close)
      end

      def formatter=(_formatter)
        # Do nothing
      end

      def formatter
        nil
      end

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

      def respond_to_missing?(method, include_private = false)
        @loggers.any? { |logger| logger.respond_to?(method, include_private) } || super
      end

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
