require "securial/config/validation"
require "securial/config/signature"
require "securial/helpers/regex_helper"

module Securial
  module Config
    class Configuration
      def initialize
        Securial::Config::Signature.default_config_attributes.each do |attr, default_value|
          instance_variable_set("@#{attr}", default_value)
        end
      end

      Securial::Config::Signature.default_config_attributes.each_key do |attr|
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
