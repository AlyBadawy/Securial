require "rails_helper"

RSpec.describe Securial::UsersController, type: :request do
  let(:securial_user) { create(:securial_user) }
  let(:valid_attributes) {
    {
      email_address: "test@example.com",
      password: "Pa$$w0rd",
      password_confirmation: "Pa$$w0rd",
      username: "test",
      first_name: "Test",
      last_name: "User",
      phone: "1234567890",
      bio: "Test user",
    }
  }
  let(:invalid_attributes) {
    {
      email_address: "test@example.com",
      password: "password",
      password_confirmation: "invalid",
    }
  }
  let(:expected_keys) {
    %w[
      id first_name last_name phone username bio created_at updated_at url
    ]
  }

  before do
    @admin_headers = auth_headers(admin: true)
  end

  describe "GET /index" do
    it "returns http success" do
      get securial.users_path, headers: @admin_headers, as: :json
      expect(response).to be_successful
    end

    it "renders a JSON response with all users as an array" do
      securial_user
      get securial.users_path, headers: @admin_headers, as: :json
      expect(response.content_type).to match(a_string_including("application/json"))
      res_body = JSON.parse(response.body)
      expect(res_body.keys).to match_array(%w[records count url])
      records = res_body["records"]
      expect(records).to be_an(Array)
      expect(records.length).to eq(2)
      expect(records[1]["username"]).to eq(securial_user.username)
    end

    describe "unauthorized access", skip: "authentication is not implemented yet" do
      it_behaves_like "unauthorized request", :get, -> { securial.users_path }, :no_token
      it_behaves_like "unauthorized request", :get, -> { securial.users_path }, :invalid_token
      it_behaves_like "unauthorized request", :get, -> { securial.users_path }, :regular_user
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get securial.user_path(securial_user), headers: @admin_headers, as: :json
      expect(response).to be_successful
    end

    it "renders a JSON response of the user with correct keys" do
      get securial.user_path(securial_user), headers: @admin_headers, as: :json
      expect(response.content_type).to match(a_string_including("application/json"))
      res_body = JSON.parse(response.body)
      expect(res_body.keys).to include(*expected_keys)
    end

    it "doesn't renders password_digest in the user object" do
      get securial.user_path(securial_user), headers: @admin_headers, as: :json
      response_body = JSON.parse(response.body)
      expect(response_body.keys).not_to include("password_digest")
    end

    describe "unauthorized access", skip: "authentication is not implemented yet" do
      it_behaves_like "unauthorized request", :get, -> { securial.user_path(securial_user) }, :no_token
      it_behaves_like "unauthorized request", :get, -> { securial.user_path(securial_user) }, :invalid_token
      it_behaves_like "unauthorized request", :get, -> { securial.user_path(securial_user) }, :regular_user
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post securial.users_path, params: { securial_user: valid_attributes }, headers: @admin_headers, as: :json
        }.to change(Securial::User, :count).by(1)
      end

      it "returns http created" do
        post securial.users_path, params: { securial_user: valid_attributes }, headers: @admin_headers, as: :json
        expect(response).to have_http_status(:created)
      end

      it "renders a JSON response with the correct keys" do
        post securial.users_path, params: { securial_user: valid_attributes }, headers: @admin_headers, as: :json
        expect(response.content_type).to match(a_string_including("application/json"))
        res_body = JSON.parse(response.body)
        expect(res_body.keys).to include(*expected_keys)
      end

      it "renders a JSON response with new user data" do
        post securial.users_path, params: { securial_user: valid_attributes }, headers: @admin_headers, as: :json
        res_body = JSON.parse(response.body)
        expect(res_body["username"]).to eq(valid_attributes[:username])
        expect(res_body["first_name"]).to eq(valid_attributes[:first_name])
        expect(res_body["last_name"]).to eq(valid_attributes[:last_name])
        expect(res_body["phone"]).to eq(valid_attributes[:phone])
        expect(res_body["bio"]).to eq(valid_attributes[:bio])
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post securial.users_path, params: { securial_user: invalid_attributes }, headers: @admin_headers, as: :json
        }.not_to change(Securial::User, :count)
      end

      it "renders a JSON response with errors for the new user" do
        post securial.users_path,
             params: { securial_user: invalid_attributes }, headers: @admin_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    describe "unauthorized access", skip: "authentication is not implemented yet" do
      it_behaves_like "unauthorized request", :post, -> { securial.users_path }, :no_token, -> { { securial_user: valid_attributes } }
      it_behaves_like "unauthorized request", :post, -> { securial.users_path }, :invalid_token, -> { { securial_user: valid_attributes } }
      it_behaves_like "unauthorized request", :post, -> { securial.users_path }, :regular_user, -> { { securial_user: valid_attributes } }
    end
  end

  describe "PUT /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          username: "John.doe",
          first_name: "John",
          last_name: "Doe",
          phone: "1234567891",
          bio: "John Doe is the best!",
        }
      }

      it "updates the requested securial_user" do
        put securial.user_path(securial_user), params: { securial_user: new_attributes }, headers: @admin_headers, as: :json
        securial_user.reload
        expect(response).to have_http_status(:ok)
        expect(securial_user).to have_attributes(new_attributes)
      end

      it "renders a JSON response with the user" do
        put securial.user_path(securial_user), params: { securial_user: new_attributes }, headers: @admin_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
        res_body = JSON.parse(response.body)
        expect(res_body.keys).to include(*expected_keys)
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the user" do
        put securial.user_path(securial_user), params: { securial_user: invalid_attributes }, headers: @admin_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    describe "unauthorized access", skip: "authentication is not implemented yet" do
      it_behaves_like "unauthorized request", :put, -> { securial.user_path(securial_user) }, :no_token, -> { { securial_user: new_attributes } }
      it_behaves_like "unauthorized request", :put, -> { securial.user_path(securial_user) }, :invalid_token, -> { { securial_user: new_attributes } }
      it_behaves_like "unauthorized request", :put, -> { securial.user_path(securial_user) }, :regular_user, -> { { securial_user: new_attributes } }
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested securial_user" do
      securial_user # Create the record
      expect {
        delete securial.user_path(securial_user), headers: @admin_headers, as: :json
      }.to change(Securial::User, :count).by(-1)
    end

    it "returns a 204 no content response" do
      securial_user # Create the record
      delete securial.user_path(securial_user), headers: @admin_headers, as: :json
      expect(response).to have_http_status(:no_content)
    end

    describe "unauthorized access", skip: "authentication is not implemented yet" do
      it_behaves_like "unauthorized request", :delete, -> { securial.user_path(securial_user) }, :no_token
      it_behaves_like "unauthorized request", :delete, -> { securial.user_path(securial_user) }, :invalid_token
      it_behaves_like "unauthorized request", :delete, -> { securial.user_path(securial_user) }, :regular_user
    end
  end
end
