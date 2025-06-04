require "rails_helper"

module Securial
  RSpec.describe Auth::SessionCreator do
    describe ".create_session" do
      let(:user) { create(:securial_user) }
      let(:request) do
        ActionDispatch::TestRequest.create.tap do |request|
          request.user_agent = "RSpec Test Agent"
          request.remote_ip = "127.0.0.1"
        end
      end

      context "when user is nil" do
        it "returns nil" do
          expect(described_class.create_session(nil, request)).to be_nil
        end
      end

      context "when user is not persisted" do
        it "returns nil" do
          new_user = build(:securial_user)
          expect(described_class.create_session(new_user, request)).to be_nil
        end
      end

      context "when request is not an ActionDispatch::Request" do
        it "returns nil" do
          expect(described_class.create_session(user, "Invalid Request")).to be_nil
        end
      end

      context "when all parameters are valid" do
        it "creates a new session for the user" do
          session = described_class.create_session(user, request)
          expect(session).to be_a(Securial::Session)
          expect(session.user).to eq(user)
          expect(session.refresh_token).to be_present
          expect(session.last_refreshed_at).to be_within(1.second).of(Time.current)
          expect(session.refresh_token_expires_at).to be_within(1.second).of(1.week.from_now)
        end
      end
    end
  end
end
