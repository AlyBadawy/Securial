module Securial
  #
  # Session
  #
  # # This class represents a user session in the Securial authentication system.
  # # It is used to manage user sessions, including session creation, validation,
  # and refresh functionality.
  #
  # ## Attributes
  # - `user_id`: The ID of the user associated with the session
  # - `ip_address`: The IP address from which the session was created
  # - `user_agent`: The user agent string of the browser or client used to create
  # the session
  # - `refresh_token`: A token used to refresh the session
  # - `refresh_token_expires_at`: The expiration time of the refresh token
  # - `refresh_count`: The number of times the session has been refreshed
  # - `last_refreshed_at`: The timestamp of the last time the session was refreshed
  # - `revoked`: A boolean indicating whether the session has been revoked
  #
  # ## Associations
  # - Belongs to a user, linking the session to a specific user
  #
  # ## Validations
  # - `ip_address`: Must be present
  # - `user_agent`: Must be present
  # - `refresh_token`: Must be present
  class Session < ApplicationRecord
    belongs_to :user

    validates :ip_address, presence: true
    validates :user_agent, presence: true
    validates :refresh_token, presence: true

    # Revokes the session by setting the `revoked` attribute to true.
    #
    # This method updates the session record in the database to indicate that
    # the session is no longer valid.
    #
    # @return [void] Updates the `revoked` attribute to true.
    # @raise [ActiveRecord::RecordInvalid] if the update fails due to validation errors
    # @example
    #   session.revoke! # => Updates the session to be revoked
    # @note This method does not delete the session record; it only marks it as revoked.
    #
    def revoke!
      update!(revoked: true)
    end

    # Checks if the session is valid based on its state.
    #
    # A session is considered valid if it is not revoked and has not expired.
    #
    # @return [Boolean] Returns true if the session is valid, false otherwise.
    def is_valid_session?
      !(revoked? || expired?)
    end

    # Checks if the session is valid for a specific request.
    #
    # A session is valid for a request if it is not revoked, has not expired,
    # and the IP address and user agent match those of the request.
    #
    # @param [ActionDispatch::Request] request The request to validate against
    # @return [Boolean] Returns true if the session is valid for the request, false otherwise.
    def is_valid_session_request?(request)
      is_valid_session? && ip_address == request.ip && user_agent == request.user_agent
    end

    # Refreshes the session by generating a new refresh token and updating
    # the session attributes.
    #
    # This method raises an error if the session is revoked or expired.
    #
    # @raise [Securial::Error::Auth::TokenRevokedError] if the session is revoked
    # @raise [Securial::Error::Auth::TokenExpiredError] if the session is expired
    # @return [void] Updates the session with a new refresh token and updates the refresh count and timestamps.
    # @example
    #   session.refresh! # => Updates the session with a new refresh token
    # @note This method uses the Securial::Auth::TokenGenerator to
    # generate a new refresh token and updates the session's attributes accordingly.
    # @note The refresh token expiration duration is configured in Securial.configuration.session_refresh_token_expires_in.
    #
    # @see Securial::Auth::TokenGenerator
    def refresh!
      raise Securial::Error::Auth::TokenRevokedError if revoked?
      raise Securial::Error::Auth::TokenExpiredError if expired?

      new_refresh_token = Securial::Auth::TokenGenerator.generate_refresh_token

      refresh_token_duration = Securial.configuration.session_refresh_token_expires_in

      update!(refresh_token: new_refresh_token,
              refresh_count: self.refresh_count + 1,
              last_refreshed_at: Time.current,
              refresh_token_expires_at: refresh_token_duration.from_now)
    end

    # Checks if the session is revoked.
    #
    # @return [Boolean] Returns true if the session is revoked, false otherwise.
    #
    # @example
    #   session.revoked? # => true or false
    # @note This method checks the `revoked` attribute of the session.
    # @see Securial::Session#revoked
    # @note This method is used to determine if the session is still active or has been revoked
    def revoked?; revoked; end

    # Checks if the session has expired based on the refresh token expiration time.
    #
    # A session is considered expired if the `refresh_token_expires_at` time is in the past.
    #
    # @return [Boolean] Returns true if the session has expired, false otherwise.
    def expired?; refresh_token_expires_at < Time.current; end
  end
end
