require "rails_helper"

RSpec.describe Securial do
  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| described_class.configure(&b) }.to yield_with_args(instance_of(Securial::Config::Configuration))
    end

    it "allows setting configuration values" do
      described_class.configure do |config|
        config.log_to_file = true
        config.log_to_stdout = false
        config.log_file_level = :debug
      end

      expect(described_class.configuration.log_to_file).to be true
      expect(described_class.configuration.log_to_stdout).to be false
      expect(described_class.configuration.log_file_level).to eq :debug
    end

    it "maintains configuration between calls" do
      described_class.configure do |config|
        config.log_to_file = true
      end

      described_class.configure do |config|
        config.log_to_stdout = true
      end

      expect(described_class.configuration.log_to_file).to be true
      expect(described_class.configuration.log_to_stdout).to be true
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(Securial::Config::Configuration)
    end

    it "memoizes the configuration" do
      config1 = described_class.configuration
      config2 = described_class.configuration

      expect(config1).to be(config2)
    end

    it "allows setting a custom configuration" do
      custom_config = Securial::Config::Configuration.new
      described_class.configuration = custom_config

      expect(described_class.configuration).to be(custom_config)
    end

    it "creates a new configuration if none exists" do
      described_class.configuration = nil
      expect(described_class.configuration).to be_a(Securial::Config::Configuration)
    end
  end
end
