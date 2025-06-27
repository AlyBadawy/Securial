# @title Securial Authentication Token Encoder
#
# JWT token encoding and decoding for session authentication.
#
# This module provides secure JWT token creation and validation for user sessions
# in the Securial authentication system. It handles the encoding of session data
# into JWT tokens and the secure decoding/validation of those tokens, including
# signature verification and claim validation.
#
# @example Encoding a session into a JWT token
#   session = Securial::Session.find(session_id)
#   token = Securial::Auth::AuthEncoder.encode(session)
#   # => "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIxMjM0NTY3ODkwIiwic3ViIjoiM..."
#
# @example Decoding and validating a JWT token
#   begin
#     payload = Securial::Auth::AuthEncoder.decode(token)
#     session_id = payload['jti']
#     # Use session_id to retrieve session from database
#   rescue Securial::Error::Auth::TokenDecodeError => e
#     # Handle invalid token
#   end
require "jwt"

module Securial
  module Auth
    # Handles JWT token encoding and decoding for session authentication.
    #
    # This module provides methods to securely encode session information into
    # JWT tokens and decode/validate those tokens. It uses HMAC signing with
    # a configurable secret and includes standard JWT claims for security.
    #
    # The tokens include:
    # - Session ID (jti claim) for session lookup
    # - Expiration time (exp claim) for automatic invalidation
    # - Subject (sub claim) identifying the token type
    # - Custom claims for IP address and user agent validation
    #
    # @see https://datatracker.ietf.org/doc/html/rfc7519 JWT RFC
    module AuthEncoder
      extend self

      # Encodes a session object into a signed JWT token.
      #
      # Creates a JWT token containing the session ID and metadata for later
      # validation. The token is signed using the configured secret and algorithm.
      #
      # @param [Securial::Session] session The session object to encode
      # @return [String, nil] The encoded JWT token, or nil if session is invalid
      # @raise [Securial::Error::Auth::TokenEncodeError] If JWT encoding fails
      #
      # @example
      #   session = Securial::Session.create!(user: current_user)
      #   token = AuthEncoder.encode(session)
      #   # => "eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiIxMjM0NTY3ODkw..."
      def encode(session)
        return nil unless session && session.class == Securial::Session

        base_payload = {
          jti: session.id,
          exp: expiry_duration.from_now.to_i,
          sub: "session-access-token",
          refresh_count: session.refresh_count,
        }

        session_payload = {
          ip: session.ip_address,
          agent: session.user_agent,
        }

        payload = base_payload.merge(session_payload)
        begin
          ::JWT.encode(payload, secret, algorithm, { kid: "hmac" })
        rescue JWT::EncodeError
          raise Securial::Error::Auth::TokenEncodeError
        end
      end

      # Decodes and validates a JWT token, returning the payload.
      #
      # Verifies the token signature, expiration, and other claims before
      # returning the decoded payload. The token must have been signed with
      # the current secret and must not be expired.
      #
      # @param [String] token The JWT token to decode and validate
      # @return [Hash] The decoded token payload containing session information
      # @raise [Securial::Error::Auth::TokenDecodeError] If token is invalid, expired, or malformed
      #
      # @example
      #   payload = AuthEncoder.decode("eyJhbGciOiJIUzI1NiJ9...")
      #   session_id = payload['jti']
      #   ip_address = payload['ip']
      #   user_agent = payload['agent']
      def decode(token)
        begin
          decoded = ::JWT.decode(token, secret, true, { algorithm: algorithm, verify_jti: true, iss: "securial" })
        rescue JWT::DecodeError
          raise Securial::Error::Auth::TokenDecodeError
        end
        decoded.first
      end

      private

      # Returns the secret key used for JWT signing and verification.
      #
      # @return [String] The configured session secret
      # @api private
      #
      def secret
        Securial.configuration.session_secret
      end

      # Returns the algorithm used for JWT signing.
      #
      # @return [String] The configured session algorithm in uppercase
      # @api private
      #
      def algorithm
        Securial.configuration.session_algorithm.to_s.upcase
      end

      # Returns the token expiration duration.
      #
      # @return [ActiveSupport::Duration] The configured session expiration duration
      # @api private
      #
      def expiry_duration
        Securial.configuration.session_expiration_duration
      end
    end
  end
end
