require 'rails_helper'

RSpec.describe Securial::Error do
  describe Securial::Error::BaseSecurialError do
    it "can be raised" do
      expect { raise described_class }.to raise_error(described_class)
    end

    it "uses default message when no message provided" do
      error = described_class.new
      expect(error.message).to eq("An error occurred in Securial")
    end

    it "uses custom message when provided" do
      custom_message = "Custom error message"
      error = described_class.new(custom_message)
      expect(error.message).to eq(custom_message)
    end

    it "returns empty backtrace" do
      error = described_class.new
      expect(error.backtrace).to eq([])
    end
  end

  describe Securial::Error::Config do
    describe Securial::Error::Config::InvalidConfigurationError do
      it "inherits from BaseSecurialError" do
        expect(described_class.superclass).to eq(Securial::Error::BaseSecurialError)
      end

      it "can be raised" do
        expect { raise described_class }.to raise_error(described_class)
      end

      it "uses default message when no message provided" do
        error = described_class.new
        expect(error.message).to eq("Invalid configuration for Securial")
      end

      it "uses custom message when provided" do
        custom_message = "Custom invalid configuration message"
        error = described_class.new(custom_message)
        expect(error.message).to eq(custom_message)
      end

      it "returns empty backtrace inherited from parent" do
        error = described_class.new
        expect(error.backtrace).to eq([])
      end
    end

    describe Securial::Error::Config::LoggerValidationError do
      it "inherits from BaseSecurialError" do
        expect(described_class.superclass).to eq(Securial::Error::BaseSecurialError)
      end

      it "can be raised" do
        expect { raise described_class }.to raise_error(described_class)
      end

      it "uses default message when no message provided" do
        error = described_class.new
        expect(error.message).to eq("Logger configuration validation failed")
      end

      it "uses custom message when provided" do
        custom_message = "Custom logger validation error message"
        error = described_class.new(custom_message)
        expect(error.message).to eq(custom_message)
      end

      it "returns empty backtrace inherited from parent" do
        error = described_class.new
        expect(error.backtrace).to eq([])
      end
    end
  end
end
