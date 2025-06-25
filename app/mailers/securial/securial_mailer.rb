module Securial
  #
  # SecurialMailer
  #
  # # This class serves as the mailer for Securial, handling email notifications
  # related to user account management, such as welcome emails, sign-in notifications,
  # account updates, and password recovery.
  #
  # It inherits from ApplicationMailer, allowing it to utilize the base mailer functionality
  # provided by Securial::ApplicationMailer.
  #
  # This class can be extended to add more email functionalities as needed.
  #
  class SecurialMailer < ApplicationMailer
    # Sends a welcome email to a new user.
    #
    # @param [Securial::User] securial_user The user to whom the welcome email will be sent.
    # @return [void] Sends an email with the subject defined in Securial configuration.
    def welcome(securial_user)
      @user = securial_user
      subject = Securial.configuration.mailer_sign_up_subject
      mail subject: subject, to: securial_user.email_address
    end

    # Sends a sign-in notification email.
    #
    # @param [Securial::User] securial_user The user who signed in.
    # @param [<Type>] securial_session The session information for the sign-in.
    # @return [void] Sends an email with the subject defined in Securial configuration
    def sign_in(securial_user, securial_session)
      @user = securial_user
      @session = securial_session
      subject = Securial.configuration.mailer_sign_in_subject
      mail subject: subject, to: securial_user.email_address
    end

    # Sends an account update notification email.
    #
    # @param [Securial::User] securial_user The user whose account was updated.
    # @return [void] Sends an email with the subject defined in Securial configuration.
    def update_account(securial_user)
      @user = securial_user
      subject = Securial.configuration.mailer_update_account_subject
      mail subject: subject, to: securial_user.email_address
    end

    # Sends a password recovery email.
    #
    # @param [Securial::User] securial_user The user who requested a password reset.
    # @return [void] Sends an email with the subject defined in Securial configuration
    # containing instructions for resetting the password.
    def forgot_password(securial_user)
      @user = securial_user
      subject = Securial.configuration.mailer_forgot_password_subject
      mail subject: subject, to: securial_user.email_address
    end
  end
end
