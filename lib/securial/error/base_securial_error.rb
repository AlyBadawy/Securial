module Securial
  module Error
    class BaseSecurialError < StandardError
      def initialize(message = nil)
        super(message || "An error occurred in Securial")
      end

      def backtrace; []; end
    end
  end
end
