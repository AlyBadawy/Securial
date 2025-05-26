module Securial
  module ConfigErrors
    class ConfigAdminRoleError < StandardError; end

    class ConfigSessionExpirationDurationError < StandardError; end
    class ConfigSessionAlgorithmError < StandardError; end
    class ConfigSessionSecretError < StandardError; end

    class ConfigMailerSenderError < StandardError; end
    class ConfigPasswordError < StandardError; end
  end
end
