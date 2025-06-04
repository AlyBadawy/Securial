require "securial/error"

module Securial
  module Config
    module Validation
      module SecurityValidation
        class << self
          VALID_SECURITY_HEADERS = %i[strict default none].freeze

          def validate!(securial_config)
            validate_security_headers!(securial_config)
            validate_rate_limiting!(securial_config)
          end

          private

          def validate_security_headers!(securial_config)
            unless VALID_SECURITY_HEADERS.include?(securial_config.security_headers)
              error_message = "Invalid security_headers option. Valid options are: #{VALID_SECURITY_HEADERS.map(&:inspect).join(', ')}."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SecurityValidationError, error_message
            end
          end

          def validate_rate_limiting!(securial_config) # rubocop:disable Metrics/MethodLength
            unless securial_config.rate_limiting_enabled.is_a?(TrueClass) || securial_config.rate_limiting_enabled.is_a?(FalseClass)
              error_message = "rate_limiting_enabled must be a boolean value."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SecurityValidationError, error_message
            end

            return unless securial_config.rate_limiting_enabled

            unless securial_config.rate_limit_requests_per_minute.is_a?(Integer) && securial_config.rate_limit_requests_per_minute > 0
              error_message = "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SecurityValidationError, error_message
            end

            unless securial_config.rate_limit_response_status.is_a?(Integer) && securial_config.rate_limit_response_status.between?(400, 599)
              error_message = "rate_limit_response_status must be an HTTP status code between 4xx and 5xx."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SecurityValidationError, error_message
            end

            unless securial_config.rate_limit_response_message.is_a?(String) && !securial_config.rate_limit_response_message.strip.empty?
              error_message = "rate_limit_response_message must be a non-empty String."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::SecurityValidationError, error_message
            end
          end
        end
      end
    end
  end
end
