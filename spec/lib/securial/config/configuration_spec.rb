require "rails_helper"

RSpec.describe Securial::Config::Configuration do
  let(:signature) { Securial::Config::Signature.config_signature }
  let(:defaults) { Securial::Config::Signature.default_config_attributes }

  describe "#initialize" do
    it "sets all attributes to their default values" do
      config = described_class.new
      defaults.each do |attr, default|
        expect(config.send(attr)).to eq(default)
      end
    end
  end

  describe "attribute accessors" do
    subject(:config) { described_class.new }

    it "allows reading and writing all config attributes" do
      signature.each do |key, attr|
        # Set a value, then read it back
        value = attr[:default]
        expect { config.send("#{key}=", value) }.not_to raise_error
        expect(config.send(key)).to eq(value)
      end
    end
  end

  describe "validation on assignment" do
    subject(:config) { described_class.new }

    it "raises if assigning an invalid value" do
      key = signature.keys.find { |k| Array(signature[k][:type]).include?(String) }
      expect {
        config.send("#{key}=", 123)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError)
    end

    it "raises if assigning a value not in allowed_values" do
      key = signature.keys.find { |k| signature[k][:allowed_values].is_a?(Array) && signature[k][:required] == true }
      expect {
        config.send("#{key}=", :not_allowed_value)
      }.to raise_error(Securial::Error::Config::InvalidConfigurationError)
    end
  end
end
