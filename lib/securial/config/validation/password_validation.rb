require "securial/error"

module Securial
  module Config
    module Validation
      module PasswordValidation
        class << self
          def validate!(securial_config)
            validate_password_reset_subject!(securial_config)
            validate_password_min_max_length!(securial_config)
            validate_password_complexity!(securial_config)
            validate_password_expiration!(securial_config)
            validate_password_reset_token!(securial_config)
          end

          private

          def validate_password_reset_token!(securial_config)
            if securial_config.reset_password_token_secret.blank?
              error_message = "Reset password token secret is not set."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
            unless securial_config.reset_password_token_secret.is_a?(String)
              error_message = "Reset password token secret must be a String."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
            unless securial_config.reset_password_token_expires_in.is_a?(ActiveSupport::Duration) && securial_config.reset_password_token_expires_in > 0
              error_message = "Reset password token expiration must be a valid ActiveSupport::Duration greater than 0."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
          end

          def validate_password_reset_subject!(securial_config)
            if securial_config.mailer_forgot_password_subject.blank?
              error_message = "Password reset email subject is not set."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
            unless securial_config.mailer_forgot_password_subject.is_a?(String)
              error_message = "Password reset email subject must be a String."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
          end

          def validate_password_min_max_length!(securial_config)
            unless securial_config.password_min_length.is_a?(Integer) && securial_config.password_min_length > 0
              error_message = "Password minimum length must be a positive integer."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
            unless securial_config.password_max_length.is_a?(Integer) && securial_config.password_max_length >= securial_config.password_min_length
              error_message = "Password maximum length must be an integer greater than or equal to the minimum length."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
          end

          def validate_password_complexity!(securial_config)
            if securial_config.password_complexity.nil? || !securial_config.password_complexity.is_a?(Regexp)
              error_message = "Password complexity regex is not set or is not a valid Regexp."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
          end

          def validate_password_expiration!(securial_config)
            unless securial_config.password_expires.is_a?(TrueClass) || securial_config.password_expires.is_a?(FalseClass)
              error_message = "Password expiration must be a boolean value."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end

            if securial_config.password_expires == true && (
              securial_config.password_expires_in.nil? ||
              !securial_config.password_expires_in.is_a?(ActiveSupport::Duration) ||
              securial_config.password_expires_in <= 0
              )
              error_message = "Password expiration duration is not set or is not a valid ActiveSupport::Duration."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::PasswordValidationError, error_message
            end
          end
        end
      end
    end
  end
end
