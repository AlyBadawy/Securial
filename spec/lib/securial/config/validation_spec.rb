require "rails_helper"

RSpec.describe Securial::Config::Validation do
  let(:signature) { Securial::Config::Signature.config_signature }

  # We'll use a Struct to simulate a config object with dynamic attributes
  let(:config_defaults) do
    signature.transform_values { |opts| opts[:default] }
  end
  let(:config_class) { Struct.new(*config_defaults.keys) }
  let(:valid_config) { config_class.new(*config_defaults.values) }

  describe ".validate_all!" do
    it "does not raise for a valid config" do
      expect {
        described_class.validate_all!(valid_config)
      }.not_to raise_error
    end

    it "raises if a required field is missing" do
      key = signature.keys.find { |k| signature[k][:required] == true }
      config = valid_config.dup
      config[key] = nil
      expect {
        described_class.validate_all!(config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError, /#{key} is required/)
    end

    it "raises if a dynamically required field is missing" do
      dynamic_key = signature.keys.find { |k| signature[k][:required].is_a?(String) }
      required_dep = signature[dynamic_key][:required].to_sym
      config = valid_config.dup
      config[required_dep] = true
      config[dynamic_key] = nil
      expect {
        described_class.validate_all!(config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError, /#{dynamic_key} is required but not provided when #{required_dep} is true/)
    end

    it "raises if a required field has an invalid type" do
      key = signature.keys.find { |k| Array(signature[k][:type]).include?(String) }
      config = valid_config.dup
      config[key] = 12345
      expect {
        described_class.validate_all!(config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError, /#{key} must be of type/)
    end

    it "raises if a required field has a value not in allowed_values" do
      key = signature.keys.find { |k| signature[k][:allowed_values].is_a?(Array) && signature[k][:required] == true }
      allowed = signature[key][:allowed_values]
      config = valid_config.dup
      config[key] = :not_allowed_value
      expect(allowed).not_to include(:not_allowed_value)
      expect {
        described_class.validate_all!(config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError, /#{key} must be one of/)
    end

    it "raises if a duration is negative or zero" do
      key = signature.keys.find { |k| signature[k][:type] == ActiveSupport::Duration }
      config = valid_config.dup
      config[key] = 0.seconds
      expect {
        described_class.validate_all!(config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError, /#{key} must be a positive duration/)

      config[key] = -5.minutes
      expect {
        described_class.validate_all!(config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError, /#{key} must be a positive duration/)
    end

    it "raises if a numeric is negative" do
      key = signature.keys.find { |k| signature[k][:type] == Numeric }
      config = valid_config.dup
      config[key] = -1
      expect {
        described_class.validate_all!(config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError, /#{key} must be a non-negative numeric value/)
    end

    it "raises if password_min_length > password_max_length" do
      config = valid_config.dup
      config[:password_min_length] = 20
      config[:password_max_length] = 10
      expect {
        described_class.validate_all!(config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError, /password_min_length cannot be greater than password_max_length/)
    end
  end

  describe ".validate_required_fields!" do
    it "raises for missing required fields" do
      config = valid_config.dup
      required_key = signature.keys.find { |k| signature[k][:required] == true }
      config[required_key] = nil
      expect {
        described_class.send(:validate_required_fields!, signature, config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError)
    end
  end

  describe ".validate_types_and_values!" do
    it "raises for wrong type" do
      key = signature.keys.find { |k| Array(signature[k][:type]).include?(String) }
      config = valid_config.dup
      config[key] = 97
      expect {
        described_class.send(:validate_types_and_values!, signature, config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError)
    end
  end

  describe ".validate_password_lengths!" do
    it "raises if min > max" do
      config = valid_config.dup
      config[:password_min_length] = 30
      config[:password_max_length] = 10
      expect {
        described_class.send(:validate_password_lengths!, config)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError)
    end
  end
end
