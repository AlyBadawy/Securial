module Securial
  module Config
    module Errors
      class BaseConfigError < StandardError
        def backtrace; []; end
      end

      class ConfigAdminRoleError < BaseConfigError; end

      class ConfigSessionExpirationDurationError < BaseConfigError; end
      class ConfigSessionAlgorithmError < BaseConfigError; end
      class ConfigSessionSecretError < BaseConfigError; end

      class ConfigMailerSenderError < BaseConfigError; end
      class ConfigPasswordError < BaseConfigError; end
      class ConfigResponseError < BaseConfigError; end
    end
  end
end
