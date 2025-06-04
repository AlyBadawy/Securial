module Securial
  module Error
    module Auth
      class AuthEncodeError < BaseError
        default_message "Error encoding authentication token"
      end

      class AuthDecodeError < BaseError
        default_message "Error decoding authentication token"
      end

      class AuthRevokedError < BaseError
        default_message "Auth token has been revoked"
      end

      class AuthExpiredError < BaseError
        default_message "Auth token has expired"
      end
    end
  end
end
