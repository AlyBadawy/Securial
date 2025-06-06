module Securial
  # Preview all emails at http://localhost:3000/rails/mailers/securial/securial_mailer
  class SecurialMailerPreview < ActionMailer::Preview
    def forgot_password
      SecurialMailer.forgot_password(Securial::User.first || FactoryBot.create(:securial_user))
    end

    def welcome
      SecurialMailer.welcome(Securial::User.first || FactoryBot.create(:securial_user))
    end

    def sign_in
      user = Securial::User.first || FactoryBot.create(:securial_user)
      session = user.sessions.last || FactoryBot.create(:securial_session, user: user)
      SecurialMailer.sign_in(user, session)
    end

    def update_account
      SecurialMailer.update_account(Securial::User.first || FactoryBot.create(:securial_user))
    end
  end
end
