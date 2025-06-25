module Securial
  #
  # SessionsController
  #
  # Controller for managing user authentication sessions.
  #
  # This controller handles session-related operations including:
  #   - User login and token issuance
  #   - Session listing and management
  #   - Token refresh
  #   - Session revocation and logout
  #
  # Session management is a critical security component, providing users
  # with the ability to authenticate and manage their active sessions.
  #
  # Routes typically mounted at Securial/sessions/* in the host application.
  #
  class SessionsController < ApplicationController
    skip_authentication! only: %i[login refresh]

    before_action :set_session, only: %i[show revoke logout]

    # Lists all active sessions for the current user.
    #
    # Retrieves all active sessions belonging to the authenticated user,
    # enabling users to monitor their login activity across devices.
    #
    # @return [void] Renders index view with the user's active sessions
    def index
      @securial_sessions = Current.user.sessions
    end

    # Shows details for a specific session.
    #
    # Retrieves and displays information for a single session.
    #
    # @param [Integer] params[:id] The ID of the session to display
    # @return [void] Renders show view with the specified session
    def show
    end

    # Authenticates a user and creates a new session.
    #
    # Validates the provided credentials and, if successful, creates a new
    # session and returns access and refresh tokens.
    #
    # @param [String] params[:email_address] The user's email address
    # @param [String] params[:password] The user's password
    # @return [void] Renders tokens with 201 Created status or error with 401 status
    def login
      params.require([:email_address, :password])
      if user = User.authenticate_by(params.permit([:email_address, :password]))
        render_login_response(user)
      else
        render status: :unauthorized,
               json: {
                 errors: ["Invalid email address or password."],
                 instructions: "Make sure to send the correct 'email_address' and 'password' in the payload",
               }
      end
    end

    # Ends the current user's session.
    #
    # Revokes the active session token, effectively logging the user out.
    #
    # @return [void] Returns 204 No Content status
    def logout
      @securial_session.revoke!
      Current.session = nil
      head :no_content
    end

    # Issues new tokens using a valid refresh token.
    #
    # Validates the provided refresh token and, if valid, issues new
    # access and refresh tokens to extend the user's session.
    #
    # @param [String] params[:refresh_token] The refresh token to validate
    # @return [void] Renders new tokens with 201 Created status or error with 422 status
    def refresh
      if Current.session = Securial::Session.find_by(refresh_token: params[:refresh_token])
        if Current.session.is_valid_session_request?(request)
          Current.session.refresh!
          render status: :created,
                 json: {
                   access_token: Securial::Auth::AuthEncoder.encode(Current.session),
                   refresh_token: Current.session.refresh_token,
                   refresh_token_expires_at: Current.session.refresh_token_expires_at,
                 }
          return
        end
      end
      render status: :unprocessable_entity, json: {
        error: "Invalid or expired token.",
        instructions: "Please log in again to obtain a new access token.",
      }
    end

    # Revokes a specific session.
    #
    # Invalidates the specified session, preventing further use of its tokens.
    #
    # @param [Integer] params[:id] The ID of the session to revoke
    # @return [void] Returns 204 No Content status
    def revoke
      @securial_session.revoke!
      Current.session = nil if @securial_session == Current.session
      head :no_content
    end

    # Revokes all of the current user's sessions.
    #
    # Invalidates all active sessions for the current user, forcing logout across all devices.
    #
    # @return [void] Returns 204 No Content status
    def revoke_all
      Current.user.sessions.each(&:revoke!)
      Current.session = nil
      head :no_content
    end

    private

    # Finds and sets the session to be manipulated.
    #
    # Uses the provided ID or defaults to the current session if no ID is provided.
    #
    # @return [void]
    def set_session
      id = params[:id]
      @securial_session = id ? Current.user.sessions.find(params[:id]) : Current.session
    end

    # Renders the appropriate response after successful authentication.
    #
    # Checks if the user's password has expired and either prompts for reset
    # or creates a new session with tokens for the authenticated user.
    #
    # @param [User] user The authenticated user
    # @return [void] Renders tokens with 201 Created status or error with 403 status
    def render_login_response(user)
      if user.password_expired?
        render status: :forbidden,
               json: {
                 errors: ["Password expired"],
                 instructions: "Please reset your password before logging in.",
               }
      else
        Securial::Auth::SessionCreator.create_session!(user, request)
        render status: :created,
               json: {
                 access_token: Securial::Auth::AuthEncoder.encode(Current.session),
                 refresh_token: Current.session.refresh_token,
                 refresh_token_expires_at: Current.session.refresh_token_expires_at,
               }
      end
    end
  end
end
