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

  describe ".friendly_token" do
    context "with default length" do
      subject(:method) { described_class.friendly_token }

      it "returns a string of length 20" do
        expect(method.length).to eq(20)
      end

      it "contains only URL-safe characters" do
        # URL-safe base64 characters plus our substitutions
        allowed_chars = /\A[A-Za-z0-9\-_sxyz]+\z/
        expect(method).to match(allowed_chars)
      end

      it "does not contain problematic characters" do
        # Characters that were replaced: l, I, O, 0
        expect(method).not_to include("l", "I", "O", "0")
      end

      it "generates unique tokens on multiple calls" do
        tokens = Array.new(100) { described_class.friendly_token }
        expect(tokens.uniq.length).to eq(100)
      end
    end

    context "with custom length" do
      subject(:method) { described_class.friendly_token(custom_length) }

      let(:custom_length) { 32 }


      it "returns a string of specified length" do
        expect(method.length).to eq(custom_length)
      end

      it "contains only URL-safe characters" do
        allowed_chars = /\A[A-Za-z0-9\-_sxyz]+\z/
        expect(method).to match(allowed_chars)
      end

      it "does not contain problematic characters" do
        expect(method).not_to include("l", "I", "O", "0")
      end
    end

    context "with various lengths" do
      [1, 5, 10, 16, 50, 100].each do |length|
        it "returns correct length for #{length} characters" do
          token = described_class.friendly_token(length)
          expect(token.length).to eq(length)
        end
      end
    end

    describe "character substitution" do
      before do
        # Mock SecureRandom to return a predictable string containing problematic chars
        allow(SecureRandom).to receive(:urlsafe_base64).and_return("lIO0abcdef")
      end

      it "replaces problematic characters with safe alternatives" do
        token = described_class.friendly_token(10)
        expect(token).to eq("sxyzabcdef")
      end
    end

    describe "edge cases" do
      it "handles length of 0" do
        token = described_class.friendly_token(0)
        expect(token).to eq("")
      end

      it "handles very small lengths" do
        token = described_class.friendly_token(1)
        expect(token.length).to eq(1)
      end

      it "handles very large lengths" do
        token = described_class.friendly_token(1000)
        expect(token.length).to eq(1000)
      end
    end

    describe "security properties" do
      it "generates tokens with sufficient entropy" do
        # Test that generated tokens have good distribution
        tokens = Array.new(1000) { described_class.friendly_token(10) }

        # Check that we have a good variety of characters
        all_chars = tokens.join.chars.uniq
        expect(all_chars.length).to be > 20 # Should have good character variety
      end

      it "is deterministic given the same SecureRandom output" do
        allow(SecureRandom).to receive(:urlsafe_base64).and_return("abcdefghijklmnopqrstuvwxyz")

        token1 = described_class.friendly_token(10)
        token2 = described_class.friendly_token(10)

        expect(token1).to eq(token2)
      end
    end

    describe "URL safety" do
      it "generates tokens that are URL-safe" do
        token = described_class.friendly_token(50)

        # Should not contain characters that need URL encoding
        expect(token).not_to include("+", "/", "=")

        # Should be safe to use in URLs without encoding
        encoded = CGI.escape(token)
        expect(encoded).to eq(token)
      end
    end

    describe "readability improvements" do
      it "avoids visually similar characters" do
        tokens = Array.new(100) { described_class.friendly_token(50) }
        combined = tokens.join

        # Should not contain easily confused characters
        expect(combined).not_to include("l") # looks like 1 or I
        expect(combined).not_to include("I") # looks like 1 or l
        expect(combined).not_to include("O") # looks like 0
        expect(combined).not_to include("0") # looks like O
      end

      it "uses replacement characters consistently" do
        # Mock to ensure our replacements are used
        allow(SecureRandom).to receive(:urlsafe_base64).and_return("l" * 50)

        token = described_class.friendly_token(20)
        expect(token).to eq("s" * 20)
      end
    end
  end
end
