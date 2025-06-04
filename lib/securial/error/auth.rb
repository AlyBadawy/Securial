module Securial
  module Error
    module Auth
      class TokenEncodeError < BaseError
        default_message "Error encoding authentication token"
      end

      class TokenDecodeError < BaseError
        default_message "Error decoding authentication token"
      end

      class TokenRevokedError < BaseError
        default_message "Auth token has been revoked"
      end

      class TokenExpiredError < BaseError
        default_message "Auth token has expired"
      end
    end
  end
end
