# Requires all error classes used in the Securial framework.
#
# This file serves as the central error management system for Securial,
# loading all specialized error types and establishing the Error namespace.
# Each error type extends from BaseSecurialError and provides specific
# error handling for different parts of the framework.
#
# @example Accessing a specific error type
#   begin
#     # Some operation that might fail
#   rescue Securial::Error::Auth::TokenDecodeError => e
#     # Handle token decoding errors
#   rescue Securial::Error::Config::ValidationError => e
#     # Handle configuration validation errors
#   rescue Securial::Error::BaseError => e
#     # Handle any other Securial errors
#   end
#
require "securial/error/base_securial_error"
require "securial/error/config"
require "securial/error/auth"

module Securial
  # Namespace for all Securial-specific errors and exceptions.
  #
  # The Error module contains specialized error classes for different
  # components of the Securial framework, organized into submodules
  # for better categorization:
  #
  # - {BaseError} - Base class for all Securial errors
  # - {Config} - Configuration-related errors
  # - {Auth} - Authentication and authorization errors
  #
  # @see Securial::Error::BaseError
  # @see Securial::Error::Config
  # @see Securial::Error::Auth
  #
  module Error; end
end
