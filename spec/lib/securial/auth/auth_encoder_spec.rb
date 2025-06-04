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
          decoded_payload = JWT::EncodedToken.new(token).payload
          expect(decoded_payload["jti"]).to eq(securial_session.id)
        end
      end

      context "with an invalid session" do
        it "returns nil" do
          token = described_class.encode("Invalid session")
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
        it "returns the decoded payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload).to be_a(Hash)
        end

        it "includes the session ID in the decoded payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload["jti"]).to eq(securial_session.id)
        end

        it "includes the session refresh count in the decoded payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload["refresh_count"]).to eq(securial_session.refresh_count)
        end

        it "includes the session IP address in the decoded payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload["ip"]).to eq(securial_session.ip_address)
        end

        it "includes the session user agent in the decoded payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload["agent"]).to eq(securial_session.user_agent)
        end

        it "includes the expiration time in the decoded payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload["exp"]).to be_within(1.second).of(3.minutes.from_now.to_i)
        end

        it "includes the correct keys for the payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload.keys).to include(
            "jti",
            "exp",
            "sub",
            "refresh_count",
            "ip",
            "agent",
          )
        end

        it "includes the correct values for the payload" do
          token = described_class.encode(securial_session)
          decoded_payload = described_class.decode(token)
          expect(decoded_payload).to include(
            "jti" => securial_session.id,
            "exp" => be_within(1.second).of(3.minutes.from_now.to_i),
            "sub" => "session-access-token",
            "refresh_count" => securial_session.refresh_count,
            "ip" => securial_session.ip_address,
            "agent" => securial_session.user_agent,
          )
        end
      end

      context "with an invalid token" do
        it "raises a JWT::DecodeError" do
          expect {
            described_class.decode("invalid.token")
          }.to raise_error(Securial::Error::Auth::TokenDecodeError)
        end
      end

      context "with an expired token" do
        it "raises a JWT::ExpiredSignature" do
          expired_session = create(:securial_session)
          expired_token = described_class.encode(expired_session)
          travel_to 4.minutes.from_now do
            expect {
              described_class.decode(expired_token)
            }.to raise_error(Securial::Error::Auth::TokenDecodeError)
          end
        end
      end
    end
  end
end
