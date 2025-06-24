module Securial
  module Helpers
    module RegexHelper
      EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP
      USERNAME_REGEX = /\A(?![0-9])[a-zA-Z](?:[a-zA-Z0-9]|[._](?![._]))*[a-zA-Z0-9]\z/
      PASSWORD_REGEX = %r{\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[^a-zA-Z0-9])[a-zA-Z].*\z}

      extend self
      def valid_email?(email)
        email.match?(EMAIL_REGEX)
      end

      def valid_username?(username)
        username.match?(USERNAME_REGEX)
      end
    end
  end
end
