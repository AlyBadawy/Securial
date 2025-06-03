module Securial
  module Config
    class Configuration
      def self.config_attributes
        {
          log_to_file: !Rails.env.test?,
          log_to_stdout: !Rails.env.test?,
        }
      end

      def initialize
        self.class.config_attributes.each do |attr, default_value|
          instance_variable_set("@#{attr}", default_value)
        end
        validate!
      end

      config_attributes.each_key do |attr|
        define_method(attr) { instance_variable_get("@#{attr}") }

        define_method("#{attr}=") do |value|
          instance_variable_set("@#{attr}", value)
          validate!
        end
      end

      private

      def validate!
        # TODO: write validation logic for configuration attributes
      end
    end
  end
end
