require "rails_helper"

RSpec.describe Securial::StatusController, type: :request do
  describe "GET /securial/status" do
    it "returns a successful status response" do
      get "/securial/status"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("ok")
      expect(json).to have_key("timestamp")
      expect(json).to have_key("version")
      expect(json["version"]).to eq(Securial::VERSION)
    end
  end
end
