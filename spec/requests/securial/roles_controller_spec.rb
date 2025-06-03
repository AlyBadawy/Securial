require "rails_helper"

RSpec.describe Securial::RolesController, type: :request do
  let(:securial_role) { create(:securial_role) }

  let(:valid_attributes) {
    {
      role_name: "Admin",
      hide_from_profile: true,
    }
  }

  let(:invalid_attributes) {
    { role_name: nil }
  }

  describe "GET /index" do
    it "returns http success" do
      get securial.roles_path,
          headers: @valid_headers,
          as: :json
      expect(response).to have_http_status(:success)
    end

    it "renders a JSON response with the correct keys" do
      Securial::Role.create! valid_attributes
      get securial.roles_path,
          headers: @valid_headers,
          as: :json
      expect(response.content_type).to match(a_string_including("application/json"))
      res_body = JSON.parse(response.body)
      expect(res_body.keys).to match_array(%w[records count url])
      records = res_body["records"]
      expect(records).to be_an(Array)
      expect(records.first.keys).to match_array(%w[id role_name hide_from_profile created_at updated_at url])
    end

    it "renders a JSON response with all roles as an array" do
      Securial::Role.create! valid_attributes
      get securial.roles_path,
          headers: @valid_headers,
          as: :json
      expect(response.content_type).to match(a_string_including("application/json"))
      res_body = JSON.parse(response.body)
      expect(res_body.keys).to match_array(%w[records count url])
      records = res_body["records"]
      expect(records.first["role_name"]).to eq("Admin")
      expect(records.first["hide_from_profile"]).to be(true)
    end

    it "renders a JSON response with the correct count" do
      Securial::Role.create! valid_attributes
      get securial.roles_path,
          headers: @valid_headers,
          as: :json
      expect(response.content_type).to match(a_string_including("application/json"))
      res_body = JSON.parse(response.body)
      records = res_body["records"]
      expect(res_body["count"]).to eq(1)
      expect(records.length).to eq(1)
    end

    it "renders an empty array when no roles to display" do
      get securial.roles_path,
          headers: @valid_headers,
          as: :json
      expect(response.content_type).to match(a_string_including("application/json"))
      res_body = JSON.parse(response.body)
      expect(res_body.keys).to eq(%w[records count url])
      records = res_body["records"]
      expect(records.length).to eq(0)
      expect(res_body["count"]).to eq(0)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get securial.role_path(securial_role),
          headers: @valid_headers,
          as: :json
      expect(response).to have_http_status(:success)
    end

    it "renders a JSON response of the role with correct keys" do
      get securial.role_path(securial_role),
          headers: @valid_headers,
          as: :json
      expect(response.content_type).to match(a_string_including("application/json"))
      res_body = JSON.parse(response.body)
      expect(res_body.keys).to eq(%w[id role_name hide_from_profile created_at updated_at url])
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Role" do
        expect {
          post securial.roles_path,
               params: { securial_role: valid_attributes },
               headers: @valid_headers,
               as: :json
        }.to change(Securial::Role, :count).by(1)
      end

      it "returns http created" do
        post securial.roles_path,
             params: { securial_role: valid_attributes },
             headers: @valid_headers,
             as: :json
        expect(response).to have_http_status(:created)
      end

      it "renders a JSON response with the new role" do
        post securial.roles_path,
             params: { securial_role: valid_attributes },
             headers: @valid_headers,
             as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
        res_body = JSON.parse(response.body)
        expect(res_body["role_name"]).to eq("Admin")
        expect(res_body["hide_from_profile"]).to be(true)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Role" do
        expect {
          post securial.roles_path,
               params: { securial_role: invalid_attributes },
               headers: @valid_headers,
               as: :json
        }.not_to change(Securial::Role, :count)
      end

      it "renders a JSON response with errors for the new role" do
        post securial.roles_path,
             params: { securial_role: invalid_attributes }, headers: @valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "PUT /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          role_name: "User",
          hide_from_profile: false,
        }
      }

      it "updates the requested securial_role" do
        put securial.role_path(securial_role),
            params: { securial_role: new_attributes },
            headers: @valid_headers,
            as: :json
        securial_role.reload
        expect(response).to have_http_status(:ok)
        expect(securial_role.role_name).to eq("User")
        expect(securial_role.hide_from_profile).to be(false)
      end

      it "renders a JSON response with the role" do
        put securial.role_path(securial_role),
            params: { securial_role: new_attributes },
            headers: @valid_headers,
            as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the role" do
        put securial.role_path(securial_role),
            params: { securial_role: invalid_attributes },
            headers: @valid_headers,
            as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested securial_role" do
      securial_role # Create the record
      expect {
        delete securial.role_path(securial_role),
               headers: @valid_headers,
               as: :json
      }.to change(Securial::Role, :count).by(-1)
    end

    it "renders a no_content response" do
      delete securial.role_path(securial_role),
             headers: @valid_headers,
             as: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end
