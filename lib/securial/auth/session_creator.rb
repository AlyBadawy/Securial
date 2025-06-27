# @title Securial Session Creator
#
# Session creation utilities for the Securial authentication system.
#
# This module provides functionality to create authenticated user sessions with
# proper token generation and metadata tracking. It handles the validation of
# user and request objects before creating database records and setting up
# the current session context.
#
# @example Creating a session for a user
#   user = Securial::User.find_by(email: "user@example.com")
#   session = Securial::Auth::SessionCreator.create_session!(user, request)
#   # => #<Securial::Session id: "abc123", user_id: "user123", ...>
#
# @example Handling invalid inputs
#   invalid_session = Securial::Auth::SessionCreator.create_session!(nil, request)
#   # => nil
module Securial
  module Auth
    # Creates and manages user authentication sessions.
    #
    # This module provides methods to create new authenticated sessions for users,
    # including proper validation of inputs, generation of refresh tokens, and
    # setting up session metadata such as IP addresses and user agents.
    #
    # Created sessions are automatically set as the current session context and
    # include all necessary tokens and expiration information for secure
    # authentication management.
    #
    module SessionCreator
      extend self

      # Creates a new authenticated session for the given user and request.
      #
      # Validates the provided user and request objects, then creates a new session
      # record with appropriate metadata and tokens. The newly created session is
      # automatically set as the current session context.
      #
      # @param [Securial::User] user The user object to create a session for
      # @param [ActionDispatch::Request] request The HTTP request object containing metadata
      # @return [Securial::Session, nil] The created session object, or nil if validation fails
      #
      # @example Creating a session after successful authentication
      #   user = Securial::User.authenticate(email, password)
      #   if user
      #     session = SessionCreator.create_session!(user, request)
      #     # User is now authenticated with active session
      #   end
      #
      # @example Handling validation failures
      #   # Invalid user (not persisted)
      #   new_user = Securial::User.new
      #   session = SessionCreator.create_session!(new_user, request)
      #   # => nil
      def create_session!(user, request)
        valid_user = user && user.is_a?(Securial::User) && user.persisted?
        valid_request = request.is_a?(ActionDispatch::Request)

        return nil unless valid_user && valid_request

        user.sessions.create!(
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          refresh_token: Securial::Auth::TokenGenerator.generate_refresh_token,
          last_refreshed_at: Time.current,
          refresh_token_expires_at: 1.week.from_now,
        ).tap do |session|
          Current.session = session
        end
      end
    end
  end
end
