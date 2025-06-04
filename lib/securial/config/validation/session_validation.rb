require "securial/error"

module Securial
  module Config
    module Validation
      module SessionValidation
        class << self
          VALID_SESSION_ENCRYPTION_ALGORITHMS = %i[hs256 hs384 hs512].freeze

          def validate!(securial_config)
            validate_session_expiry_duration!(securial_config)
            validate_session_algorithm!(securial_config)
            validate_session_secret!(securial_config)
          end

          private

          def validate_session_expiry_duration!(securial_config)
            if securial_config.session_expiration_duration.nil?
              error_message = "Session expiration duration is not set."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SessionValidationError, error_message
            end
            if securial_config.session_expiration_duration.class != ActiveSupport::Duration
              error_message = "Session expiration duration must be an ActiveSupport::Duration."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SessionValidationError, error_message
            end
            if securial_config.session_expiration_duration <= 0
              Securial.logger.fatal("Session expiration duration must be greater than 0.")
              raise Securial::Error::Config::SessionValidationError, "Session expiration duration must be greater than 0."
            end
          end

          def validate_session_algorithm!(securial_config)
            if securial_config.session_algorithm.blank?
              error_message = "Session algorithm is not set."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SessionValidationError, error_message
            end
            unless securial_config.session_algorithm.is_a?(Symbol)
              error_message = "Session algorithm must be a Symbol."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SessionValidationError, error_message
            end
            unless VALID_SESSION_ENCRYPTION_ALGORITHMS.include?(securial_config.session_algorithm)
              error_message = "Invalid session algorithm. Valid options are: #{VALID_SESSION_ENCRYPTION_ALGORITHMS.map(&:inspect).join(', ')}."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SessionValidationError, error_message
            end
          end

          def validate_session_secret!(securial_config)
            if securial_config.session_secret.blank?
              error_message = "Session secret is not set."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SessionValidationError, error_message
            end
            unless securial_config.session_secret.is_a?(String)
              error_message = "Session secret must be a String."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SessionValidationError, error_message
            end
          end
        end
      end
    end
  end
end
