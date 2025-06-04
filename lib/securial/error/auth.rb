module Securial
  module Error
    module Auth
      class TokenEncodeError < BaseError
        default_message "Error while encoding session token"
      end

      class TokenDecodeError < BaseError
        default_message "Error while decoding session token"
      end

      class TokenRevokedError < BaseError
        default_message "Session token is revoked"
      end

      class TokenExpiredError < BaseError
        default_message "Session token is expired"
      end
    end
  end
end
