module Securial
  module Auth
    module SessionCreator
      module_function

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
