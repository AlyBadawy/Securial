module Securial
  # Identity Concern
  #
  # Provides authentication and user identification functionality for controllers.
  # This concern adds before_action hooks for user identification and authentication,
  # and provides helper methods for accessing the current user and enforcing authentication.
  #
  module Identity
    extend ActiveSupport::Concern

    included do
      before_action :identify_user
      before_action :authenticate_user!
      helper_method :current_user if respond_to?(:helper_method)
    end

    class_methods do
      # Skips authentication for specified controller actions, making them publicly accessible.
      #
      # This class method allows you to bypass the `authenticate_user!` before_action
      # that is applied by default to all controller actions when including the Identity concern.
      # It's useful for endpoints that should be publicly accessible, such as landing pages,
      # password reset, login, or registration.
      #
      # @param [Hash] options Options to pass to skip_before_action
      # @option options [Symbol, Array<Symbol>] :only Specific action(s) to skip authentication for
      # @option options [Symbol, Array<Symbol>] :except Action(s) to exclude from skipping
      #
      # @example Skip authentication for login and registration actions
      #   class SessionsController < ApplicationController
      #     include Securial::Identity
      #
      #     skip_authentication! only: [:new, :create]
      #
      #     def new
      #       # Login form action
      #     end
      #
      #     def create
      #       # Authentication logic
      #     end
      #   end
      #
      # @example Skip authentication for all actions except protected ones
      #   class PublicController < ApplicationController
      #     include Securial::Identity
      #
      #     skip_authentication! except: [:dashboard, :account]
      #   end
      #
      # @return [void]
      def skip_authentication!(**options)
        skip_before_action :authenticate_user!, **options
      end
    end


    # Returns the currently authenticated user or nil if no user is authenticated.
    #
    # This method provides access to the current user object from the session
    # tracked in Current.session.
    #
    # @return [Securial::User, nil] The current authenticated user or nil
    #
    def current_user
      Current.session&.user
    end

    # Ensures the current user has admin privileges.
    #
    # This method checks if a user is authenticated and has admin privileges.
    # If the user is not an admin, it renders a forbidden response.
    # If no user is authenticated, it calls authenticate_user! to handle the unauthorized case.
    #
    # @return [void]
    def authenticate_admin!
      if current_user
        return if current_user.is_admin?

        render status: :forbidden, json: { error: "You are not authorized to perform this action" }
      else
        authenticate_user!
      end
    end

    private

    # Identifies the current user from the Authorization header.
    #
    # This method attempts to identify the user by:
    # 1. Checking for a valid Bearer token in the Authorization header
    # 2. Decoding the token to extract the session ID
    # 3. Finding and validating the corresponding session
    # 4. Ensuring IP address and user agent match for security
    #
    # If identification succeeds, the session is stored in Current.session
    #
    # @return [void]
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

    # Ensures a user is authenticated before proceeding.
    #
    # This method checks if a user has been successfully identified.
    # If not, it renders an unauthorized response and halts the request.
    # Internal Rails requests are exempt from authentication requirements.
    #
    # @return [void]
    def authenticate_user!
      return if internal_rails_request?
      return if Current.session&.user

      render status: :unauthorized, json: { error: "You are not signed in" } and return
    end

    # Determines if the current request is from internal Rails controllers.
    #
    # This method checks if the current controller is one of Rails' internal
    # controllers (Info, Mailers, Welcome) which should bypass authentication.
    #
    # @return [Boolean] true if the request is from internal Rails controllers, false otherwise
    def internal_rails_request?
      defined?(Rails::InfoController) && is_a?(Rails::InfoController) ||
      defined?(Rails::MailersController) && is_a?(Rails::MailersController) ||
      defined?(Rails::WelcomeController) && is_a?(Rails::WelcomeController)
    end
  end
end
