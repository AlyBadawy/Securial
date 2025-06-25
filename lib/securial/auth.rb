# @title Securial Authentication System
#
# Core authentication components for the Securial framework.
#
# This file serves as the entry point for authentication-related functionality in Securial,
# loading specialized modules that handle token generation, encoding/decoding, and session management.
# These components work together to provide a secure, flexible authentication system supporting
# token-based and session-based authentication patterns.
#
# @example Encoding a session token
#   # Create an encoded JWT representing a user session
#   token = Securial::Auth::AuthEncoder.encode(user_session)
#   # => "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIxMjM0NTY3ODkwIiwic3ViIjoiM..."
#
# @example Creating a new user session
#   # Authenticate user and create a new session with tokens
#   Securial::Auth::SessionCreator.create_session!(user, request)
#
#   # Access the newly created session
#   current_session = Current.session
#
# @example Generating secure tokens
#   # Generate a password reset token
#   reset_token = Securial::Auth::TokenGenerator.friendly_token
#   # => "aBc123DeF456gHi789"
#
require "securial/auth/auth_encoder"
require "securial/auth/session_creator"
require "securial/auth/token_generator"

module Securial
  # Namespace for authentication-related functionality in the Securial framework.
  #
  # The Auth module contains components that work together to provide a complete
  # authentication system for Securial-powered applications:
  #
  # - {AuthEncoder} - Handles JWT token encoding and decoding with security measures
  # - {SessionCreator} - Creates and manages authenticated user sessions
  # - {TokenGenerator} - Generates secure random tokens for various authentication needs
  #
  # These components handle the cryptographic and security aspects of user authentication,
  # ensuring that best practices are followed for token generation, validation, and session
  # management throughout the application lifecycle.
  #
  # @see Securial::Auth::AuthEncoder
  # @see Securial::Auth::SessionCreator
  # @see Securial::Auth::TokenGenerator
  #
  module Auth; end
end
