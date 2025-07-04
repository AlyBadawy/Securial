require "spec_helper"

RSpec.describe Securial::Auth::TokenGenerator do
  describe ".generate_refresh_token" do
    let(:dummy_secret) { "super$ecret" }
    let(:config) { instance_double(Securial::Config::Configuration, session_secret: dummy_secret) }

    before do
      stub_const("Securial::Auth::TokenGenerator", described_class)
      allow(Securial).to receive(:configuration).and_return(config)
      # Freeze SecureRandom output for predictability
      allow(SecureRandom).to receive(:hex).with(32).and_return("a" * 64)
    end

    it "returns a string with the correct format" do
      token = described_class.generate_refresh_token
      # Should be 64 chars (hmac) + 64 chars (random_data) = 128 chars, all hex
      expect(token).to match(/\A[a-f0-9]{128}\z/)
    end

    it "uses the configured session_secret" do
      # Use have_received pattern instead of expect().to receive()
      described_class.generate_refresh_token
      expect(config).to have_received(:session_secret)
    end

    it "uses SecureRandom.hex(32) for the random_data" do
      described_class.generate_refresh_token
      expect(SecureRandom).to have_received(:hex).with(32)
    end

    it "generates different tokens if SecureRandom changes" do
      allow(SecureRandom).to receive(:hex).with(32).and_return("b" * 64)
      token = described_class.generate_refresh_token
      expect(token).not_to eq(OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA256"), dummy_secret, "a" * 64) + "a" * 64)
    end

    it "prepends the HMAC of the random data, using the secret and SHA256" do
      expected_hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("SHA256"), dummy_secret, "a" * 64)
      token = described_class.generate_refresh_token
      expect(token).to start_with(expected_hmac)
      expect(token).to end_with("a" * 64)
    end

    it "produces a unique token on each call" do
      # Remove previous stubs to allow real randomness
      allow(SecureRandom).to receive(:hex).with(32).and_call_original
      tokens = Array.new(5) { described_class.generate_refresh_token }
      expect(tokens.uniq.length).to eq(5)
    end
  end

  describe ".generate_password_reset_token" do
    it "generates a token with the format XXXXXX-XXXXXX" do
      token = described_class.generate_password_reset_token
      expect(token).to match(/\A[a-zA-Z0-9]{6}-[a-zA-Z0-9]{6}\z/)
    end

    it "generates a different token each time" do
      token1 = described_class.generate_password_reset_token
      token2 = described_class.generate_password_reset_token
      expect(token1).not_to eq(token2)
    end

    it "generates only alphanumeric characters and a dash" do
      token = described_class.generate_password_reset_token
      expect(token.delete('-')).to match(/\A[a-zA-Z0-9]{12}\z/)
    end
  end
end
