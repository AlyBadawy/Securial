require "rails_helper"

RSpec.describe Securial::Config::Validation::SessionValidation do
  describe ".validate!" do
    let(:config) { instance_double(Securial::Config::Configuration) }

    context "with valid configuration" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :hs256,
          session_secret: "supersecret",
          session_refresh_token_expires_in: 1.week
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
          session_secret: "supersecret",
          session_refresh_token_expires_in: 1.week
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session expiration duration is not set."
        )
      end
    end

    context "with invalid session expiration duration type" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: "1 hour", # Not an ActiveSupport::Duration
          session_algorithm: :hs256,
          session_secret: "supersecret",
          session_refresh_token_expires_in: 1.week
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session expiration duration must be an ActiveSupport::Duration."
        )
      end
    end

    context "with zero session expiration duration" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 0.seconds,
          session_algorithm: :hs256,
          session_secret: "supersecret",
          session_refresh_token_expires_in: 1.week
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session expiration duration must be greater than 0."
        )
      end
    end

    context "with missing session algorithm" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: nil,
          session_secret: "supersecret",
          session_refresh_token_expires_in: 1.week
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session algorithm is not set."
        )
      end
    end

    context "with invalid session algorithm type" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: 12345, # Not a Symbol
          session_secret: "supersecret",
          session_refresh_token_expires_in: 1.week
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session algorithm must be a Symbol."
        )
      end
    end

    context "with invalid session algorithm" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :invalid_algorithm,
          session_secret: "supersecret",
          session_refresh_token_expires_in: 1.week
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
          session_secret: nil,
          session_refresh_token_expires_in: 1.week
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
          session_secret: 12345, # Not a String
          session_refresh_token_expires_in: 1.week
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session secret must be a String."
        )
      end
    end

    context "with missing session refresh token expiration" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :hs256,
          session_secret: 'supersecret',
          session_refresh_token_expires_in: nil
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session refresh token expiration duration is not set."
        )
      end
    end

    context "with invalid session refresh token expiration type" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :hs256,
          session_secret: "supersecret",
          session_refresh_token_expires_in: "1 week" # Not an ActiveSupport::Duration
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session refresh token expiration duration must be an ActiveSupport::Duration."
        )
      end
    end

    context "with zero session refresh token expiration" do
      before do
        allow(config).to receive_messages(
          session_expiration_duration: 1.hour,
          session_algorithm: :hs256,
          session_secret: "supersecret",
          session_refresh_token_expires_in: 0.seconds
        )
      end

      it "raises SessionValidationError" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::SessionValidationError,
          "Session refresh token expiration duration must be greater than 0."
        )
      end
    end
  end
end
