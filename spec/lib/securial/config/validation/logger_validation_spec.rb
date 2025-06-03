require "rails_helper"

RSpec.describe Securial::Config::Validation::LoggerValidation do
  describe "LEVELS constant" do
    it "defines the expected log levels" do
      expected_levels = %i[debug info warn error fatal unknown]
      expect(described_class::LEVELS).to eq(expected_levels)
    end
  end

  describe ".validate!" do
    let(:config) { instance_double(Securial::Config::Configuration) }

    context "with valid configuration" do
      before do
        allow(config).to receive_messages(
          log_to_file: true,
          log_to_stdout: false,
          log_file_level: :info,
          log_stdout_level: :warn
        )
      end

      it "does not raise errors" do
        expect { described_class.validate!(config) }.not_to raise_error
      end
    end

    context "with invalid boolean values" do
      before do
        allow(config).to receive_messages(
          log_to_file: "not-a-boolean",
          log_to_stdout: false,
          log_file_level: :info,
          log_stdout_level: :warn
        )
      end

      it "raises an Securial::Error::Config::LoggerValidationError with a descriptive message" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::LoggerValidationError,
          /log_to_file must be a boolean\. Allowed values: true, false\. Received: "not-a-boolean"/
        )
      end
    end

    context "with invalid log level" do
      before do
        allow(config).to receive_messages(
          log_to_file: true,
          log_to_stdout: false,
          log_file_level: :invalid_level,
          log_stdout_level: :warn
        )
      end

      it "raises an Securial::Error::Config::LoggerValidationError with symbol values properly formatted" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::LoggerValidationError,
          /log_file_level must be a symbol\. Allowed values: :debug, :info, :warn, :error, :fatal, :unknown\. Received: :invalid_level/
        )
      end
    end

    context "with another log level value" do
      before do
        allow(config).to receive_messages(
          log_to_file: true,
          log_to_stdout: true,
          log_file_level: :debug,
          log_stdout_level: "error"
        )
      end

      it "raises an Securial::Error::Config::LoggerValidationError for non-symbol log level" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::LoggerValidationError,
          /log_stdout_level must be a symbol\. Allowed values: :debug, :info, :warn, :error, :fatal, :unknown\. Received: "error"/
        )
      end
    end
  end
end
