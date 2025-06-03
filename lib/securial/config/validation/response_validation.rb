require "securial/error"

module Securial
  module Config
    module Validation
      module ResponseValidation
        class << self
          VALID_TIMESTAMP_OPTIONS = %i[all admins_only none].freeze
          VALID_RESPONSE_KEYS_FORMATS = %i[snake_case lowerCamelCase UpperCamelCase].freeze

          def validate!(config)
            validate_response_keys_format!(config)
            validate_timestamps_in_response!(config)
          end

          private

          def validate_response_keys_format!(config)
            unless VALID_RESPONSE_KEYS_FORMATS.include?(config.response_keys_format)
              error_message = "Invalid response_keys_format option. Valid options are: #{VALID_RESPONSE_KEYS_FORMATS.map(&:inspect).join(', ')}."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::ResponseValidationError, error_message
            end
          end

          def validate_timestamps_in_response!(config)
            unless VALID_TIMESTAMP_OPTIONS.include?(config.timestamps_in_response)
              error_message = "Invalid timestamps_in_response option. Valid options are: #{VALID_TIMESTAMP_OPTIONS.map(&:inspect).join(', ')}."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::ResponseValidationError, error_message
            end
          end
        end
      end
    end
  end
end
