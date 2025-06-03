require "rails_helper"

RSpec.describe Securial::Config::Validation do
  describe ".validate_all!" do
    it "calls LoggerValidation.validate! with the config object" do
      config = Securial::Config::Configuration.new
      allow(Securial::Config::Validation::LoggerValidation).to receive(:validate!)
      described_class.validate_all!(config)
      expect(Securial::Config::Validation::LoggerValidation).to have_received(:validate!).with(config)
    end

    it "calls RolesValidation.validate! with the config object" do
      config = Securial::Config::Configuration.new
      allow(Securial::Config::Validation::RolesValidation).to receive(:validate!)
      described_class.validate_all!(config)
      expect(Securial::Config::Validation::RolesValidation).to have_received(:validate!).with(config)
    end

    it "calls SessionValidation.validate! with the config object" do
      config = Securial::Config::Configuration.new
      allow(Securial::Config::Validation::SessionValidation).to receive(:validate!)
      described_class.validate_all!(config)
      expect(Securial::Config::Validation::SessionValidation).to have_received(:validate!).with(config)
    end

    it "calls MailerValidation.validate! with the config object" do
      config = Securial::Config::Configuration.new
      allow(Securial::Config::Validation::MailerValidation).to receive(:validate!)
      described_class.validate_all!(config)
      expect(Securial::Config::Validation::MailerValidation).to have_received(:validate!).with(config)
    end

    it "calls PasswordValidation.validate! with the config object" do
      config = Securial::Config::Configuration.new
      allow(Securial::Config::Validation::PasswordValidation).to receive(:validate!)
      described_class.validate_all!(config)
      expect(Securial::Config::Validation::PasswordValidation).to have_received(:validate!).with(config)
    end

    it "calls ResponseValidation.validate! with the config object" do
      config = Securial::Config::Configuration.new
      allow(Securial::Config::Validation::ResponseValidation).to receive(:validate!)
      described_class.validate_all!(config)
      expect(Securial::Config::Validation::ResponseValidation).to have_received(:validate!).with(config)
    end

    it "calls SecurityValidation.validate! with the config object" do
      config = Securial::Config::Configuration.new
      allow(Securial::Config::Validation::SecurityValidation).to receive(:validate!)
      described_class.validate_all!(config)
      expect(Securial::Config::Validation::SecurityValidation).to have_received(:validate!).with(config)
    end
  end
end
