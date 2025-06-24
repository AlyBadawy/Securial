module Securial
  # Controller for managing user password operations in the Securial authentication system.
  #
  # This controller handles password-related operations including:
  #   - Forgot password functionality
  #   - Password reset with secure tokens
  #
  # All actions in this controller skip standard authentication requirements to allow
  # unauthenticated users to recover their accounts.
  class PasswordsController < ApplicationController
    skip_authentication!
    before_action :set_user_by_password_token, only: %i[ reset_password ]

    # Initiates the password reset process for a user.
    #
    # Looks up a user by email address and, if found, generates a secure reset token
    # and sends password reset instructions via email. To prevent user enumeration attacks,
    # returns the same success response regardless of whether the email exists.
    #
    # @param email_address [String] The email address of the user requesting password reset
    # @return [void] Renders success message with 200 OK status
    def forgot_password
      if user = User.find_by(email_address: params.require(:email_address))
        user.generate_reset_password_token!
        Securial::SecurialMailer.forgot_password(user).deliver_later
      end

      render status: :ok, json: { message: "Password reset instructions sent (if user with that email address exists)." }
    end

    # Resets a user's password using a valid reset token.
    #
    # Validates the provided token, clears it to prevent reuse, and updates
    # the user's password if the new password is valid.
    #
    # @param token [String] The password reset token from the email
    # @param password [String] The new password
    # @param password_confirmation [String] Confirmation of the new password
    # @return [void] Renders success message with 200 OK status or errors with 422
    def reset_password
      @user.clear_reset_password_token!
      if @user.update(params.permit(:password, :password_confirmation))
        render status: :ok, json: { message: "Password has been reset." }
      else
        render status: :unprocessable_entity, json: { errors: @user.errors }
      end
    end

    private

    # Locates and validates a user by their password reset token.
    #
    # Sets @user instance variable if the token is valid and not expired.
    # Renders an error response if the token is invalid or expired.
    #
    # @param token [String] The password reset token to validate
    # @return [void]
    def set_user_by_password_token
      @user = User.find_by_reset_password_token!(params[:token]) # rubocop:disable Rails/DynamicFindBy
      unless @user.reset_password_token_valid?
        render status: :unprocessable_entity, json: { errors: { token: "is invalid or has expired" } } and return
      end
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      render status: :unprocessable_entity, json: { errors: { token: "is invalid or has expired" } } and return
    end
  end
end
