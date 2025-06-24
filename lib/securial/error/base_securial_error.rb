module Securial
  module Error
    class BaseError < StandardError
      class_attribute :_default_message, instance_writer: false

      def self.default_message(message = nil)
        self._default_message = message if message
        self._default_message
      end

      def initialize(message = nil)
        super(message || self.class._default_message || "An error occurred in Securial")
      end

      def backtrace; []; end
    end
  end
end
