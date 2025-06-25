# @title Securial Authentication Errors
#
# Authentication-related errors for the Securial framework.
#
# This file defines error classes for authentication-related issues in the
# Securial framework, such as token encoding/decoding failures, expired tokens,
# and revoked sessions. These errors help identify and troubleshoot problems
# with the authentication system during runtime.
#
# @example Handling authentication errors
#   begin
#     decoded_token = Securial::Auth::AuthEncoder.decode(token)
#   rescue Securial::Error::Auth::TokenDecodeError => e
#     # Handle invalid token format
#     logger.warn("Invalid token format: #{e.message}")
#   rescue Securial::Error::Auth::TokenExpiredError => e
#     # Handle expired token
#     render json: { error: "Your session has expired. Please log in again." }, status: :unauthorized
#   rescue Securial::Error::Auth::TokenRevokedError => e
#     # Handle revoked token
#     render json: { error: "Your session has been revoked." }, status: :unauthorized
#   end
#
module Securial
  module Error
    # Namespace for authentication-related errors in the Securial framework.
    #
    # These errors are raised during authentication operations such as
    # token encoding/decoding, session validation, and access control checks.
    #
    module Auth
      # Error raised when a JWT token cannot be encoded properly.
      #
      # This may occur due to invalid payload data, missing required claims,
      # or issues with the signing key.
      #
      # @see Securial::Auth::AuthEncoder#encode
      #
      class TokenEncodeError < BaseError
        default_message "Error while encoding session token"
      end

      # Error raised when a JWT token cannot be decoded or validated.
      #
      # This may occur due to malformed tokens, invalid signatures,
      # or tokens that don't match the expected format.
      #
      # @see Securial::Auth::AuthEncoder#decode
      #
      class TokenDecodeError < BaseError
        default_message "Error while decoding session token"
      end

      # Error raised when attempting to use a token from a revoked session.
      #
      # This occurs when a token references a session that has been
      # explicitly revoked, such as after a user logout or account suspension.
      #
      class TokenRevokedError < BaseError
        default_message "Session token is revoked"
      end

      # Error raised when attempting to use an expired token.
      #
      # This occurs when a token's expiration time (exp claim) has passed,
      # indicating that the token is no longer valid for authentication.
      #
      class TokenExpiredError < BaseError
        default_message "Session token is expired"
      end
    end
  end
end
