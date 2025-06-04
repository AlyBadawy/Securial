require "securial/error"

module Securial
  module Config
    module Validation
      module LoggerValidation
        class << self
          LEVELS = %i[debug info warn error fatal unknown].freeze

          def validate!(securial_config)
            allowed_options = {
              log_to_file: [securial_config.log_to_file, [true, false], "boolean"],
              log_to_stdout: [securial_config.log_to_stdout, [true, false], "boolean"],
              log_file_level: [securial_config.log_file_level, LEVELS, "symbol"],
              log_stdout_level: [securial_config.log_stdout_level, LEVELS, "symbol"],
            }

            allowed_options.each do |attr, (value, allowed, type)|
              unless allowed.include?(value)
                allowed_values = type == "symbol" ? allowed.map { |v| ":#{v}" }.join(", ") : allowed.join(", ")
                raise Securial::Error::Config::LoggerValidationError, "#{attr} must be a #{type}. Allowed values: #{allowed_values}. Received: #{value.inspect}"
              end
            end
          end
        end
      end
    end
  end
end
