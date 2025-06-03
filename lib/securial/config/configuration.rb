require "securial/config/validation"

module Securial
  module Config
    class Configuration
      def self.default_config_attributes
        {
          log_to_file: !Rails.env.test?,
          log_to_stdout: !Rails.env.test?,
          log_file_level: :debug,
          log_stdout_level: :debug,
        }
      end

      def initialize
        self.class.default_config_attributes.each do |attr, default_value|
          instance_variable_set("@#{attr}", default_value)
        end
        validate!
      end

      default_config_attributes.each_key do |attr|
        define_method(attr) { instance_variable_get("@#{attr}") }

        define_method("#{attr}=") do |value|
          instance_variable_set("@#{attr}", value)
          validate!
        end
      end

      private

      def validate!
        Securial::Config::Validation.validate_all!(self)
      end
    end
  end
end
