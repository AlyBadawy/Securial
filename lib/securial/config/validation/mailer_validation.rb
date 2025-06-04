require "securial/error"

module Securial
  module Config
    module Validation
      module MailerValidation
        class << self
          def validate!(securial_config)
            if securial_config.mailer_sender.blank?
              error_message = "Mailer sender is not set."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::MailerValidationError, error_message
            end
            if securial_config.mailer_sender !~  URI::MailTo::EMAIL_REGEXP
              error_message = "Mailer sender is not a valid email address."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::MailerValidationError, error_message
            end
          end
        end
      end
    end
  end
end
