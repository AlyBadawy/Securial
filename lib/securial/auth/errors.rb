module Securial
  module Auth
    module Errors
      class BaseAuthError < StandardError
        def backtrace; []; end
      end

      class AuthEncodeError < BaseAuthError; end
      class AuthDecodeError < BaseAuthError; end

      class AuthRevokedError < BaseAuthError; end
      class AuthExpiredError < BaseAuthError; end
    end
  end
end
