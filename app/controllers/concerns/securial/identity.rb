module Securial
  module Identity
    extend ActiveSupport::Concern

    included do
      before_action :identify_user
      before_action :authenticate_user!
      helper_method :current_user if respond_to?(:helper_method)
    end

    class_methods do
      def skip_authentication!(**options)
        skip_before_action :authenticate_user!, **options
      end
    end


    def current_user
      Current.session&.user
    end

    def authenticate_admin!
      return if internal_rails_request?

      if current_user
        return if current_user&.is_admin?

        render status: :forbidden, json: { error: "You are not authorized to perform this action" }
      else
        authenticate_user!
      end
    end

    private

    def identify_user
      return if internal_rails_request?

      Current.session = nil
      auth_header = request.headers["Authorization"]
      if auth_header.present? && auth_header.start_with?("Bearer ")
        token = auth_header.split(" ").last
        begin
          decoded_token = Securial::Auth::AuthEncoder.decode(token)
          session = Session.find_by(id: decoded_token["jti"], revoked: false)
          if session.present? &&
             session.is_valid_session? &&
             session.ip_address == request.remote_ip &&
             session.user_agent == request.user_agent
            Current.session = session
          end
        rescue Securial::Error::Auth::TokenDecodeError, ActiveRecord::RecordNotFound => e
          Securial.logger.debug "Authentication failed: #{e.message}"
        end
      end
    end

    def authenticate_user!
      return if internal_rails_request?
      return if Current.session&.user

      render status: :unauthorized, json: { error: "You are not signed in" } and return
    end

    def internal_rails_request?
      defined?(Rails::InfoController) && is_a?(Rails::InfoController) ||
      defined?(Rails::MailersController) && is_a?(Rails::MailersController) ||
      defined?(Rails::WelcomeController) && is_a?(Rails::WelcomeController)
    end
  end
end
