require "rails_helper"

RSpec.describe Securial::Config::Validation do
  describe ".validate_all!" do
    it "calls LoggerValidation.validate! with the config object" do
      config = Securial::Config::Configuration.new
      allow(Securial::Config::Validation::LoggerValidation).to receive(:validate!)

      described_class.validate_all!(config)

      expect(Securial::Config::Validation::LoggerValidation).to have_received(:validate!).with(config)
    end
  end
end
