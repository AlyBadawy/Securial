module Securial
  module Sessions
    module Errors
      class BaseSessionError < StandardError
        def backtrace; []; end
      end

      class SessionEncodeError < BaseSessionError; end
      class SessionDecodeError < BaseSessionError; end

      class SessionRevokedError < BaseSessionError; end
      class SessionExpiredError < BaseSessionError; end
    end
  end
end
