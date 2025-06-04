module Securial
  module Error
    class BaseError < StandardError
      def self.default_message(message = nil)
        @default_message = message if message
        @default_message
      end

      def initialize(message = nil)
        super(message || self.class.default_message || "An error occurred in Securial")
      end

      def backtrace; []; end
    end
  end
end
