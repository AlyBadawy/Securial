module Securial
  module Logger
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
