module Securial
  class SecurialMailer < ApplicationMailer
    def welcome(securial_user)
      @user = securial_user
      subject = Securial.configuration.mailer_sign_up_subject
      mail subject: subject, to: securial_user.email_address
    end

    def sign_in(securial_user, securial_session)
      @user = securial_user
      @session = securial_session
      subject = Securial.configuration.mailer_sign_in_subject
      mail subject: subject, to: securial_user.email_address
    end

    def update_account(securial_user)
      @user = securial_user
      subject = Securial.configuration.mailer_update_account_subject
      mail subject: subject, to: securial_user.email_address
    end

    def forgot_password(securial_user)
      @user = securial_user
      subject = Securial.configuration.mailer_forgot_password_subject
      mail subject: subject, to: securial_user.email_address
    end
  end
end
