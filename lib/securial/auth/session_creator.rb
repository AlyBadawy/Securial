module Securial
  module Auth
    module SessionCreator
      module_function

      def create_session(user, request)
        return nil unless user && user.persisted? && request.is_a?(ActionDispatch::Request)

        user.sessions.create!(
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          refresh_token: SecureRandom.hex(64),
          last_refreshed_at: Time.current,
          refresh_token_expires_at: 1.week.from_now,
        ).tap do |session|
          Current.session = session
        end
      end
    end
  end
end
