require "rails_helper"

module Securial
  RSpec.describe Auth::AuthEncoder do
    let(:securial_session) { create(:securial_session) }

    describe "The .encode class method" do
      context "with a valid session" do
        it "returns a JWT token for that session" do
          token = described_class.encode(securial_session)
          expect(token).not_to be_nil
          expect(token).to be_a(String)
        end

        it "includes the session ID in the token payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload["jti"]).to eq(securial_session.id)
        end

        it "encodes a token with the correct structure" do
          token = described_class.encode(securial_session)
          expect(token.split('.').length).to eq(3) # Header, payload, signature parts
        end

        it "creates a token that can be verified by JWT library directly" do
          token = described_class.encode(securial_session)
          decoded = nil
          expect { 
            decoded = ::JWT.decode(
              token, 
              Securial.configuration.session_secret, 
              true, 
              { algorithm: Securial.configuration.session_algorithm.to_s.upcase }
            ) 
          }.not_to raise_error
          expect(decoded.first["jti"]).to eq(securial_session.id)
        end
      end

      context "with an invalid session" do
        it "returns nil" do
          token = described_class.encode("Invalid session")
          expect(token).to be_nil
        end

        it "returns nil when session is nil" do
          token = described_class.encode(nil)
          expect(token).to be_nil
        end
      end

      context "with invalid algorithm" do
        before do
          allow(Securial.configuration).to receive(:session_algorithm).and_return("invalid_algorithm")
        end

        it "raises a AuthEncodeError" do
          expect {
            described_class.encode(securial_session)
          }.to raise_error(Securial::Error::Auth::TokenEncodeError, "Error while encoding session token")
        end
      end
    end

    describe "The .decode class method" do
      context "with a valid token" do
        # ... existing tests ...

        it "properly handles issuer validation" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload).to be_a(Hash)
        end

        it "uses the configured secret key" do
          original_secret = Securial.configuration.session_secret
          allow(Securial.configuration).to receive(:session_secret).and_return("different_secret")
          
          token = described_class.encode(securial_session)
          
          # Restore original secret and try to decode
          allow(Securial.configuration).to receive(:session_secret).and_return(original_secret)
          expect {
            described_class.decode(token)
          }.to raise_error(Securial::Error::Auth::TokenDecodeError)
        end

        it "uses the configured algorithm" do
          # Assuming default is HS256, try with HS384
          original_algorithm = Securial.configuration.session_algorithm
          allow(Securial.configuration).to receive(:session_algorithm).and_return("HS384")
          
          token = described_class.encode(securial_session)
          
          # Restore original algorithm and try to decode
          allow(Securial.configuration).to receive(:session_algorithm).and_return(original_algorithm)
          expect {
            described_class.decode(token)
          }.to raise_error(Securial::Error::Auth::TokenDecodeError)
        end
      end

      context "with a tampered token" do
        it "raises a TokenDecodeError" do
          token = described_class.encode(securial_session)
          parts = token.split('.')
          tampered_token = "#{parts[0]}.#{Base64.urlsafe_encode64('{"jti":"tampered"}')}.#{parts[2]}"
          
          expect {
            described_class.decode(tampered_token)
          }.to raise_error(Securial::Error::Auth::TokenDecodeError)
        end
      end
    end

    describe "configuration integration" do
      it "uses the configured session expiration duration" do
        custom_duration = 10.minutes
        allow(Securial.configuration).to receive(:session_expiration_duration).and_return(custom_duration)
        
        token = described_class.encode(securial_session)
        decoded_payload = described_class.decode(token)
        
        expect(decoded_payload["exp"]).to be_within(1.second).of(custom_duration.from_now.to_i)
      end
    end
  end
end
