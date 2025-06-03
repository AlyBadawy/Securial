require "rails_helper"

RSpec.describe Securial::Config::Validation::ResponseValidation do
  describe ".validate!" do
    let(:config) { instance_double(Securial::Config::Configuration) }

    context "with valid configuration" do
      before do
        allow(config).to receive_messages(
          response_keys_format: :snake_case,
          timestamps_in_response: :all
        )
      end

      it "does not raise errors" do
        expect { described_class.validate!(config) }.not_to raise_error
      end
    end

    context "with invalid response_keys_format" do
      before do
        allow(config).to receive_messages(
          response_keys_format: :invalid_format,
          timestamps_in_response: :all
        )
      end

      it "raises an Securial::Error::Config::ResponseValidationError with a descriptive message" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::ResponseValidationError,
          /Invalid response_keys_format option. Valid options are: :snake_case, :lowerCamelCase, :UpperCamelCase\./
        )
      end
    end

    context "with invalid timestamps_in_response" do
      before do
        allow(config).to receive_messages(
          response_keys_format: :snake_case,
          timestamps_in_response: :invalid_option
        )
      end

      it "raises an Securial::Error::Config::ResponseValidationError with a descriptive message" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::ResponseValidationError,
          /Invalid timestamps_in_response option. Valid options are: :all, :admins_only, :none\./
        )
      end
    end
  end
end
