require "rails_helper"

module Securial
  RSpec.describe Session, type: :model do
    let(:securial_user) { create(:securial_user) }
    let(:securial_session) { create(:securial_session, user: securial_user) }

    describe "factory" do
      it "has a valid factory" do
        expect(build(:securial_session)).to be_valid
      end
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:ip_address) }
      it { is_expected.to validate_presence_of(:user_agent) }
      it { is_expected.to validate_presence_of(:refresh_token) }
    end

    describe "associations" do
      it { is_expected.to belong_to(:user) }
    end

    describe "The #revoke! instance method" do
      it "sets revoked to true" do
        securial_session.revoke!
        expect(securial_session.reload.revoked).to be true
      end
    end

    describe "The #is_valid_session? instance method" do
      context "when the session is not revoked and not expired" do
        it "returns true" do
          expect(securial_session.is_valid_session?).to be true
        end
      end

      context "when the session is revoked" do
        it "returns false" do
          securial_session.revoke!
          expect(securial_session.is_valid_session?).to be false
        end
      end

      context "when the session is expired" do
        it "returns false" do
          securial_session.update!(refresh_token_expires_at: 1.minute.ago)
          expect(securial_session.is_valid_session?).to be false
        end
      end
    end

    describe "The #refresh! instance method" do
      before do
        allow(Securial.configuration).to receive(:session_refresh_token_expires_in).and_return(1.week)
      end

      context "when the session is valid" do
        it "does not raise an error" do
          expect { securial_session.refresh! }.not_to raise_error
        end

        it "updates the refresh_token and refresh_token_expires_at" do
          expect {
            securial_session.refresh!
          }.to change { securial_session.reload.refresh_token }.and change { securial_session.reload.refresh_token_expires_at }.to (be_within(1.second).of(1.week.from_now))
        end

        it "increments the refresh_count" do
          expect {
            securial_session.refresh!
          }.to change { securial_session.reload.refresh_count }.by(1)
        end

        it "updates the last_refreshed_at" do
          expect {
            securial_session.refresh!
          }.to change { securial_session.reload.last_refreshed_at }.to be_within(1.second).of(Time.current)
        end

        it "does not change the revoked status" do
          expect {
            securial_session.refresh!
          }.not_to change { securial_session.reload.revoked }
        end

        it "does not change the user agent" do
          expect {
            securial_session.refresh!
          }.not_to change { securial_session.reload.user_agent }
        end

        it "does not change the IP address" do
          expect {
            securial_session.refresh!
          }.not_to change { securial_session.reload.ip_address }
        end

        it "does not change the user" do
          expect {
            securial_session.refresh!
          }.not_to change { securial_session.reload.user }
        end
      end

      context "when the session is revoked" do
        before { securial_session.revoke! }

        it "raises an error" do
          expect { securial_session.refresh! }.to raise_error("Session token is revoked")
        end
      end

      context "when the session is expired" do
        before { securial_session.update!(refresh_token_expires_at: 1.minute.ago) }

        it "raises an error" do
          expect { securial_session.refresh! }.to raise_error("Session token is expired")
        end
      end
    end
  end
end
