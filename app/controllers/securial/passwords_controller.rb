module Securial
  class PasswordsController < ApplicationController
    skip_authentication!
    before_action :set_user_by_password_token, only: %i[ reset_password ]

    def forgot_password
      if user = User.find_by(email_address: params.require(:email_address))
        user.generate_reset_password_token!
        Securial::SecurialMailer.forgot_password(user).deliver_later
      end

      render status: :ok, json: { message: "Password reset instructions sent (if user with that email address exists)." }
    end

    def reset_password
      @user.clear_reset_password_token!
      if @user.update(params.permit(:password, :password_confirmation))
        render status: :ok, json: { message: "Password has been reset." }
      else
        render status: :unprocessable_entity, json: { errors: @user.errors }
      end
    end

    private

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
