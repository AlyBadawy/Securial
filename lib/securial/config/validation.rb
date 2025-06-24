require "securial/logger"

module Securial
  module Config
    module Validation
      extend self
      def validate_all!(securial_config)
        signature = Securial::Config::Signature.config_signature

        validate_required_fields!(signature, securial_config)
        validate_types_and_values!(signature, securial_config)
        validate_password_lengths!(securial_config)
      end

      private

      def validate_required_fields!(signature, config)
        signature.each do |key, options|
          value = config.send(key)
          required = options[:required]
          if required == true && value.nil?
            raise_error("#{key} is required but not provided.")
          elsif required.is_a?(String)
            dynamic_required = config.send(required)
            signature[key][:required] = dynamic_required
            if dynamic_required && value.nil?
              raise_error("#{key} is required but not provided when #{required} is true.")
            end
          end
        end
      end

      def validate_types_and_values!(signature, config)
        signature.each do |key, options|
          next unless signature[key][:required]
          value = config.send(key)
          types = Array(options[:type])

          unless types.any? { |type| value.is_a?(type) }
            raise_error("#{key} must be of type(s) #{types.join(', ')}, but got #{value.class}.")
          end

          if options[:type] == ActiveSupport::Duration && value <= 0
            raise_error("#{key} must be a positive duration, but got #{value}.")
          end

          if options[:type] == Numeric && value < 0
            raise_error("#{key} must be a non-negative numeric value, but got #{value}.")
          end

          if options[:allowed_values] && options[:allowed_values].exclude?(value)
            raise_error("#{key} must be one of #{options[:allowed_values].join(', ')}, but got #{value}.")
          end
        end
      end

      def validate_password_lengths!(config)
        if config.password_min_length > config.password_max_length
          raise_error("password_min_length cannot be greater than password_max_length.")
        end
      end

      def raise_error(msg)
        Securial.logger.fatal msg
        raise Securial::Error::Config::InvalidConfigurationError, msg
      end
    end
  end
end
