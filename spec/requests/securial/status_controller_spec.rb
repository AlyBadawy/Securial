require "rails_helper"

RSpec.describe Securial::StatusController, type: :request do
  describe "GET /securial/status" do
    it "returns a successful status response" do
      get "/securial/status"
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("ok")
      expect(json).to have_key("timestamp")
    end

    it "logs the status check" do
      allow(Securial.logger).to receive(:info)
      get "/securial/status"
      expect(Securial.logger).to have_received(:info).with("Status check initiated")
    end

    context "when user is authenticated but not admin" do
      let(:trio) { create_auth_trio }
      let(:valid_headers) { auth_headers(token: trio.third) }

      it "Doesn't show the version" do
        get "/securial/status", headers: valid_headers
        json = JSON.parse(response.body)
        expect(json).not_to have_key("version")
      end
    end

    context "when the user is an admin" do
      let(:trio) { create_auth_trio(admin: true) }
      let(:valid_headers) { auth_headers(token: trio.third) }

      it "shows the version" do
        get "/securial/status", headers: valid_headers
        json = JSON.parse(response.body)
        expect(json).to have_key("version")
        expect(json["version"]).to eq(Securial::VERSION)
      end
    end
  end
end
