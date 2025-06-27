# @title Securial Token Generator
#
# Secure token generation utilities for the Securial authentication system.
#
# This module provides cryptographically secure token generation for various
# authentication purposes, including refresh tokens and password reset tokens.
# All tokens are generated using secure random sources and include appropriate
# entropy for their intended use cases.
#
# @example Generating a refresh token
#   refresh_token = Securial::Auth::TokenGenerator.generate_refresh_token
#   # => "a1b2c3d4e5f6...9876543210abcdef1234567890"
#
# @example Generating a password reset token
#   reset_token = Securial::Auth::TokenGenerator.generate_password_reset_token
#   # => "aBc123-DeF456"
#
require "openssl"
require "securerandom"

module Securial
  module Auth
    # Generates secure tokens for authentication operations.
    #
    # This module provides methods to generate cryptographically secure tokens
    # for different authentication scenarios. All tokens use secure random
    # generation and appropriate cryptographic techniques to ensure uniqueness
    # and security.
    module TokenGenerator
      extend self

      # Generates a secure refresh token using HMAC and random data.
      #
      # Creates a refresh token by combining an HMAC signature with random data,
      # providing both integrity verification and sufficient entropy. The token
      # is suitable for long-term storage and session refresh operations.
      #
      # @return [String] A secure refresh token (96 characters hexadecimal)
      #
      # @example
      #   token = TokenGenerator.generate_refresh_token
      #   # => "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456789012345678901234567890abcdef"
      #
      # @see #generate_password_reset_token
      #
      def generate_refresh_token
        secret = Securial.configuration.session_secret
        algo = "SHA256"

        random_data = SecureRandom.hex(32)
        digest = OpenSSL::Digest.new(algo)
        hmac = OpenSSL::HMAC.hexdigest(digest, secret, random_data)

        "#{hmac}#{random_data}"
      end

      # Generates a user-friendly password reset token.
      #
      # Creates a short, alphanumeric token formatted for easy user entry.
      # The token is suitable for password reset flows where users need to
      # manually enter the token from an email or SMS message.
      #
      # @return [String] A formatted password reset token (format: "ABC123-DEF456")
      #
      # @example
      #   token = TokenGenerator.generate_password_reset_token
      #   # => "aBc123-DeF456"
      #
      # @note This token has lower entropy than refresh tokens and should have
      #   shorter expiration times and rate limiting protection.
      #
      # @see #generate_refresh_token
      #
      def generate_password_reset_token
        token = SecureRandom.alphanumeric(12)
        "#{token[0, 6]}-#{token[6, 6]}"
      end

      # Generates a URL-safe friendly token for general use.
      #
      # Creates a secure, URL-safe token suitable for various authentication
      # operations that require a balance between security and usability.
      #
      # @param [Integer] length The desired length of the generated token (default: 20)
      # @return [String] A URL-safe token containing letters, numbers, and safe symbols
      #
      # @example
      #   token = TokenGenerator.friendly_token
      #   # => "aBcDeF123456GhIjKl78"
      #
      # @example With custom length
      #   token = TokenGenerator.friendly_token(32)
      #   # => "aBcDeF123456GhIjKl789012MnOpQr34"
      #
      def friendly_token(length = 20)
        SecureRandom.urlsafe_base64(length).tr("lIO0", "sxyz")[0, length]
      end
    end
  end
end
