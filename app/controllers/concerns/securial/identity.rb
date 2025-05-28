module Securial
  module Identity
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_user!
      helper_method :current_user if respond_to?(:helper_method)
    end

    class_methods do
      def skip_authentication!(**options)
        skip_before_action :authenticate_user!, **options
      end
    end

    def authenticate_admin!
      unless current_user.is_admin?
        render status: :forbidden, json: { error: "You are not authorized to perform this action" } and return
      end
    end

    def current_user
      Current.session&.user
    end

    private

    def authenticate_user!
      return if internal_rails_request?

      auth_header = request.headers["Authorization"]
      if auth_header.present? && auth_header.start_with?("Bearer ")
        token = auth_header.split(" ").last
        begin
          decoded_token = Securial::Sessions::SessionEncoder.decode(token)
          Current.session = Session.find_by!(id: decoded_token["jti"], revoked: false)
        rescue Sessions::Errors::SessionDecodeError, ActiveRecord::RecordNotFound => e
          render status: :unauthorized, json: { error: "Invalid token: #{e.message}" } and return
        end
      else
        render status: :unauthorized, json: { error: "Missing or invalid Authorization header" } and return
      end
    end

    def start_new_session_for(user)
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

    def create_jwt_for_current_session
      Securial::Sessions::SessionEncoder.encode(Current.session)
    end

    def internal_rails_request?
      defined?(Rails::InfoController) && is_a?(Rails::InfoController) ||
      defined?(Rails::MailersController) && is_a?(Rails::MailersController) ||
      defined?(Rails::WelcomeController) && is_a?(Rails::WelcomeController)
    end
  end
end
