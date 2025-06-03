require "rails_helper"
require "securial/config/configuration"

RSpec.describe "Securial Config" do
  let(:config_instance) { Securial::Config::Configuration.new }

  before do
    Securial.instance_variable_set(:@configuration, nil)
  end

  describe ".configuration" do
    it "returns an instance of Config::Configuration" do
      expect(Securial.configuration).to be_a(Securial::Config::Configuration)
    end

    it "memoizes the configuration object" do
      config1 = Securial.configuration
      config2 = Securial.configuration
      expect(config1).to equal(config2)
    end
  end

  describe ".configuration=" do
    it "sets the configuration if it's a Config::Configuration" do
      Securial.configuration = config_instance
      expect(Securial.configuration).to eq(config_instance)
    end

    it "raises ArgumentError if not a Config::Configuration" do
      expect {
        Securial.configuration = Object.new
      }.to raise_error(ArgumentError, "Expected an instance of Securial::Config::Configuration")
    end
  end

  describe ".configure" do
    it "yields the configuration to a block" do
      expect { |b| Securial.configure(&b) }.to yield_with_args(Securial.configuration)
    end

    it "does nothing if no block is given" do
      expect { Securial.configure }.not_to raise_error
    end

    it "allows modifying configuration attributes" do
      Securial.configure do |config|
        config.log_to_file = false
        config.log_to_stdout = false
      end
      expect(Securial.configuration.log_to_file).to be_falsy
      expect(Securial.configuration.log_to_stdout).to be_falsy
    end
  end
end
