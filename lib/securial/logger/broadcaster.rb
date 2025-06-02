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
    end
  end
end
