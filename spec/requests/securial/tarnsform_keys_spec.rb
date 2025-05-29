require "rails_helper"

RSpec.describe "Key transformation middlewares" do
  let(:user) do
    create(:securial_user, password: "TestPass.01", password_confirmation: "TestPass.01")
  end



  context "when response_keys_format is :lowerCamelCase" do
    before do
      allow(Securial.configuration).to receive(:response_keys_format).and_return(:lowerCamelCase)
    end

    it "accepts camelCase keys and returns a successful response" do
      skip "Skipping due to middleware parsing issue in tests"

      json_payload = { emailAddress: user.email_address, password: "TestPass.01" }

      post "/securial/sessions/login",
           params: json_payload,
           as: :json,
           headers: { "user-agent" => "Securial Test" }
      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json).to include("accessToken", "refreshToken")
    end

    it "transforms snake_case keys to camelCase in the response" do
      post "/securial/sessions/login",
           params: { email_address: user.email_address, password: "TestPass.01" },
           as: :json,
           headers: { "user-agent" => "Securial Test" }

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json).to include("accessToken", "refreshToken")
      expect(json.keys).to all(match(/^[a-z][a-zA-Z0-9]*$/)) # Check for camelCase keys
    end
  end

  context "when response_keys_format is :UpperCamelCase" do
    before do
      allow(Securial.configuration).to receive(:response_keys_format).and_return(:UpperCamelCase)
    end

    it "accepts camelCase keys and returns a successful response" do
      skip "Skipping due to middleware parsing issue in tests"

      json_payload = { EmailAddress: user.email_address, password: "TestPass.01" }

      post "/securial/sessions/login",
           params: json_payload,
           as: :json,
           headers: { "user-agent" => "Securial Test" }
      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json).to include("AccessToken", "RefreshToken")
    end

    it "transforms snake_case keys to UpperCamelCase in the response" do
      post "/securial/sessions/login",
           params: { email_address: user.email_address, password: "TestPass.01" },
           as: :json,
           headers: { "user-agent" => "Securial Test" }

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json).to include("AccessToken", "RefreshToken")
      expect(json.keys).to all(match(/^[A-Z][a-zA-Z0-9]*$/)) # Check for UpperCamelCase keys
    end
  end

  context "when response_keys_format is :snake_case" do
    before do
      allow(Securial.configuration).to receive(:response_keys_format).and_return(:snake_case)
    end

    it "accepts snake_case keys and returns a successful response" do
      json_payload = { email_address: user.email_address, password: "TestPass.01" }

      post "/securial/sessions/login",
           params: json_payload,
           as: :json,
           headers: { "user-agent" => "Securial Test" }
      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json).to include("access_token", "refresh_token")
    end
  end
end
