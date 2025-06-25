# @title Securial Base Error
#
# Base error class for the Securial framework.
#
# This file defines the base error class that all other specialized Securial
# errors inherit from. It provides functionality for default error messages
# and customized backtrace handling.
#
module Securial
  module Error
    # Base error class for all Securial-specific exceptions.
    #
    # This class serves as the foundation for Securial's error hierarchy, providing
    # common functionality like default messages and backtrace customization.
    # All specialized error types in Securial should inherit from this class.
    #
    # @example Defining a custom error class
    #   module Securial
    #     module Error
    #       class AuthError < BaseError
    #         default_message "Authentication failed"
    #       end
    #     end
    #   end
    #
    # @example Raising a custom error
    #   raise Securial::Error::AuthError
    #   # => Authentication failed (Securial::Error::AuthError)
    #
    #   raise Securial::Error::AuthError, "Invalid token provided"
    #   # => Invalid token provided (Securial::Error::AuthError)
    #
    class BaseError < StandardError
      class_attribute :_default_message, instance_writer: false

      # Sets or gets the default message for this error class.
      #
      # This class method allows error classes to define a standard message
      # that will be used when no explicit message is provided at instantiation.
      #
      # @param message [String, nil] The default message to set for this error class
      # @return [String, nil] The current default message for this error class
      #
      def self.default_message(message = nil)
        self._default_message = message if message
        self._default_message
      end

      # Initializes a new error instance with the provided message or default.
      #
      # @param message [String, nil] The error message or nil to use default
      # @return [BaseError] New error instance
      #
      def initialize(message = nil)
        super(message || self.class._default_message || "An error occurred in Securial")
      end

      # Returns an empty backtrace.
      #
      # This method overrides the standard backtrace behavior to return an empty array,
      # which helps keep error responses clean without showing internal implementation
      # details in production environments.
      #
      # @return [Array] An empty array
      #
      def backtrace; []; end
    end
  end
end
