module Securial
  module SessionErrors
    class SessionRevokedError < StandardError; end
    class SessionExpiredError < StandardError; end
  end
end
