require_relative "auth/errors"
require_relative "auth/auth_encoder"
require_relative "auth/session_creator"

module Securial
  module Auth
    # This module serves as a namespace for authentication-related components.
    # It requires all key auth files: Errors, AuthEncoder, SessionCreator.
  end
end
