module Securial
  class SessionsController < ApplicationController
    skip_authentication! only: %i[login refresh]

    before_action :set_session, only: %i[show revoke logout]

    def index
      @securial_sessions = Current.user.sessions
    end

    def show
    end

    def login
      params.require([:email_address, :password])
      if user = User.authenticate_by(params.permit([:email_address, :password]))
        render_login_response(user)
      else
        render status: :unauthorized,
               json: {
                 error: "Invalid email address or password.",
                 instructions: "Make sure to send the correct 'email_address' and 'password' in the payload",
               }
      end
    end

    def logout
      @securial_session.revoke!
      Current.session = nil
      head :no_content
    end

    def refresh
      if Current.session = Session.find_by(refresh_token: params[:refresh_token])
        if Current.session.is_valid_session? &&
           Current.session.ip_address == request.ip &&
           Current.session.user_agent == request.user_agent
          Current.session.refresh!
          render status: :created,
                 json: {
                   access_token: create_jwt_for_current_session,
                   refresh_token: Current.session.refresh_token,
                   refresh_token_expires_at: Current.session.refresh_token_expires_at,
                 }
          return
        end
      end
      render status: :unprocessable_entity, json: { error: "Invalid or expired token." }
    end

    def revoke
      @securial_session.revoke!
      Current.session = nil if @securial_session == Current.session
      head :no_content
    end

    def revoke_all
      Current.user.sessions.each(&:revoke!)
      Current.session = nil
      head :no_content
    end

    private

    def set_session
      id = params[:id]
      @securial_session = id ? Current.user.sessions.find(params.expect(:id)) : Current.session
    end

    def render_login_response(user)
      if user.password_expired?
        render status: :forbidden,
               json: {
                 error: "Password expired",
                 instructions: "Please reset your password before logging in.",
               }
      else
        start_new_session_for user
        render status: :created,
               json: {
                 access_token: create_jwt_for_current_session,
                 refresh_token: Current.session.refresh_token,
                 refresh_token_expires_at: Current.session.refresh_token_expires_at,
               }
      end
    end
  end
end
