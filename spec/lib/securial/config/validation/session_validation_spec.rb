require "rails_helper"

RSpec.describe Securial::Config::Validation::SessionValidation do
  describe ".validate!" do
    let(:config) { instance_double(Securial::Config::Configuration) }

    context "with valid configuration" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :hs256,
          session_secret: "supersecret"
        )
      end

      it "does not raise errors" do
        expect { described_class.validate!(config) }.not_to raise_error
      end
    end

    context "with missing session expiration duration" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: nil,
          session_algorithm: :hs256,
          session_secret: "supersecret"
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session expiration duration is not set."
        )
      end
    end

    context "with invalid session algorithm" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :invalid_algorithm,
          session_secret: "supersecret"
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Invalid session algorithm. Valid options are: :hs256, :hs384, :hs512."
        )
      end
    end

    context "with missing session secret" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :hs256,
          session_secret: nil
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session secret is not set."
        )
      end
    end

    context "with invalid session secret type" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :hs256,
          session_secret: 12345 # Not a String
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session secret must be a String."
        )
      end
    end
  end
end
