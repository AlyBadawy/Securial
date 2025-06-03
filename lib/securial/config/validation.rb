require "securial/logger"
require "securial/config/validation/logger_validation"
require "securial/config/validation/roles_validation"
require "securial/config/validation/session_validation"
require "securial/config/validation/mailer_validation"
require "securial/config/validation/password_validation"
require "securial/config/validation/response_validation"
require "securial/config/validation/security_validation"

module Securial
  module Config
    module Validation
      class << self
        def validate_all!(securial_config)
          Securial::Config::Validation::LoggerValidation.validate!(securial_config)
          Securial::Config::Validation::RolesValidation.validate!(securial_config)
          Securial::Config::Validation::SessionValidation.validate!(securial_config)
          Securial::Config::Validation::MailerValidation.validate!(securial_config)
          Securial::Config::Validation::PasswordValidation.validate!(securial_config)
          Securial::Config::Validation::ResponseValidation.validate!(securial_config)
          Securial::Config::Validation::SecurityValidation.validate!(securial_config)
        end
      end
    end
  end
end
