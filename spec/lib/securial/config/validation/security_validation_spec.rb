require "spec_helper"

RSpec.describe Securial::Config::Validation::SecurityValidation do
  let(:config) do
    Struct.new(
      :security_headers,
      :rate_limiting_enabled,
      :rate_limit_requests_per_minute,
      :rate_limit_response_status,
      :rate_limit_response_message
    ).new(
      :strict,
      true,
      100,
      429,
      "Too many requests"
    )
  end

  before do
    stub_const("Securial::Error::Config::SecurityValidationError", Class.new(StandardError))
    allow(Securial).to receive(:logger).and_return(instance_double(Logger, fatal: nil))
  end

  describe ".validate!" do
    it "calls all validation methods" do
      allow(described_class).to receive(:validate_security_headers!).and_call_original
      allow(described_class).to receive(:validate_rate_limiting!).and_call_original

      described_class.validate!(config)

      expect(described_class).to have_received(:validate_security_headers!).with(config)
      expect(described_class).to have_received(:validate_rate_limiting!).with(config)
    end
  end

  describe ".validate_security_headers!" do
    it "does not raise for valid values" do
      [:strict, :default, :none].each do |valid|
        config.security_headers = valid
        expect {
          described_class.send(:validate_security_headers!, config)
        }.not_to raise_error
      end
    end

    it "raises for invalid value" do
      config.security_headers = :invalid
      expect {
        described_class.send(:validate_security_headers!, config)
      }.to raise_error(Securial::Error::Config::SecurityValidationError, /Invalid security_headers option/)
    end
  end

  describe ".validate_rate_limiting!" do
    context "when rate_limiting_enabled is not boolean" do
      it "raises for nil" do
        config.rate_limiting_enabled = nil
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limiting_enabled must be a boolean value/)
      end

      it "raises for String" do
        config.rate_limiting_enabled = "yes"
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limiting_enabled must be a boolean value/)
      end
    end

    context "when rate_limiting_enabled is false" do
      it "does not raise, skips further checks" do
        config.rate_limiting_enabled = false
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.not_to raise_error
      end
    end

    context "when rate_limiting_enabled is true" do
      before { config.rate_limiting_enabled = true }

      it "raises if rate_limit_requests_per_minute is not a positive integer" do
        config.rate_limit_requests_per_minute = nil
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_requests_per_minute must be a positive integer/)

        config.rate_limit_requests_per_minute = 0
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_requests_per_minute must be a positive integer/)

        config.rate_limit_requests_per_minute = -1
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_requests_per_minute must be a positive integer/)

        config.rate_limit_requests_per_minute = "100"
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_requests_per_minute must be a positive integer/)
      end

      it "raises if rate_limit_response_status is not HTTP 4xx-5xx" do
        config.rate_limit_requests_per_minute = 100
        config.rate_limit_response_status = 200
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_response_status must be an HTTP status code/)

        config.rate_limit_response_status = 399
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_response_status must be an HTTP status code/)

        config.rate_limit_response_status = 600
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_response_status must be an HTTP status code/)

        config.rate_limit_response_status = "429"
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_response_status must be an HTTP status code/)
      end

      it "raises if rate_limit_response_message is not a non-empty String" do
        config.rate_limit_requests_per_minute = 100
        config.rate_limit_response_status = 429

        config.rate_limit_response_message = nil
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_response_message must be a non-empty String/)

        config.rate_limit_response_message = ""
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_response_message must be a non-empty String/)

        config.rate_limit_response_message = "   "
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_response_message must be a non-empty String/)

        config.rate_limit_response_message = 123
        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.to raise_error(Securial::Error::Config::SecurityValidationError, /rate_limit_response_message must be a non-empty String/)
      end

      it "does not raise for valid config" do
        config.rate_limit_requests_per_minute = 100
        config.rate_limit_response_status = 429
        config.rate_limit_response_message = "Too many requests"

        expect {
          described_class.send(:validate_rate_limiting!, config)
        }.not_to raise_error
      end
    end
  end
end
