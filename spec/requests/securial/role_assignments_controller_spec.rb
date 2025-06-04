require "rails_helper"

RSpec.describe Securial::RoleAssignmentsController, skip: "Waiting for logging in functionality", type: :request do
  let (:securial_role) { create(:securial_role) }
  let (:securial_user) { create(:securial_user) }
  let(:valid_attributes) {
    {
      role_id: securial_role.id,
      user_id: securial_user.id,
    }
  }

  let(:invalid_attributes) {
    {
      role_id: securial_role.id,
      user_id: nil,
    }
  }

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new RoleAssignment" do
        expect {
          post securial.role_assignments_assign_url,
               params: { securial_role_assignment: valid_attributes },
               headers: @valid_headers,
               as: :json
        }.to change(Securial::RoleAssignment, :count).by(1)
      end

      it "returns http created" do
        post securial.role_assignments_assign_url,
             params: { securial_role_assignment: valid_attributes },
             headers: @valid_headers,
             as: :json
        expect(response).to have_http_status(:created)
      end

      it "renders a JSON response with the user object" do
        post securial.role_assignments_assign_url,
             params: { securial_role_assignment: valid_attributes },
             headers: @valid_headers,
             as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
        res_body = JSON.parse(response.body)
        expect(res_body["id"]).to eq(securial_user.id)
        expect(res_body["roles"].first["id"]).to eq(securial_role.id)
      end
    end

    context "with invalid parameters" do
      it "does not create a new RoleAssignment" do
        expect {
          post securial.role_assignments_assign_url,
               params: { securial_role_assignment: invalid_attributes },
               headers: @valid_headers,
               as: :json
        }.not_to change(Securial::RoleAssignment, :count)
      end

      it "renders a JSON response with errors for the new role_assignment" do
        post securial.role_assignments_assign_url,
             params: { securial_role_assignment: invalid_attributes },
             headers: @valid_headers,
             as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      context "when user_id is nil" do
        it "returns an error" do
          post securial.role_assignments_assign_url,
               params: { securial_role_assignment: invalid_attributes },
               headers: @valid_headers,
               as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("User not found")
        end
      end

      context "when role_id is nil" do
        let(:invalid_attributes) {
          {
            role_id: nil,
            user_id: securial_user.id,
          }
        }

        it "returns an error" do
          post securial.role_assignments_assign_url,
               params: { securial_role_assignment: invalid_attributes },
               headers: @valid_headers,
               as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("Role not found")
        end
      end

      context "when role_id is not a valid role" do
        let(:invalid_attributes) {
          {
            role_id: 9999,
            user_id: securial_user.id,
          }
        }

        it "returns an error" do
          post securial.role_assignments_assign_url,
               params: { securial_role_assignment: invalid_attributes },
               headers: @valid_headers,
               as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("Role not found")
        end
      end

      context "when user_id is not a valid user" do
        let(:invalid_attributes) {
          {
            role_id: securial_role.id,
            user_id: 9999,
          }
        }

        it "returns an error" do
          post securial.role_assignments_assign_url,
               params: { securial_role_assignment: invalid_attributes },
               headers: @valid_headers,
               as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("User not found")
        end
      end

      context "when role is already assigned to user" do
        before do
          Securial::RoleAssignment.create!(valid_attributes)
        end

        it "returns an error" do
          post securial.role_assignments_assign_url,
               params: { securial_role_assignment: valid_attributes },
               headers: @valid_headers,
               as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("Role already assigned to user")
        end
      end
    end
  end

  describe "DELETE /destroy" do
    context "with valid parameters" do
      it "destroys the requested securial_role_assignment" do
        Securial::RoleAssignment.create! valid_attributes
        expect {
          delete securial.role_assignments_revoke_url,
                 params: { securial_role_assignment: valid_attributes },
                 headers: @valid_headers,
                 as: :json
        }.to change(Securial::RoleAssignment, :count).by(-1)
      end

      it "renders a JSON response with the user object" do
        Securial::RoleAssignment.create! valid_attributes
        delete securial.role_assignments_revoke_url,
               params: { securial_role_assignment: valid_attributes },
               headers: @valid_headers,
               as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
        res_body = JSON.parse(response.body)
        expect(res_body["id"]).to eq(securial_user.id)
        expect(res_body["roles"]).to be_empty
      end
    end

    context "with invalid parameters" do
      it "does not revoke a role" do
        expect {
          delete securial.role_assignments_revoke_url,
                 params: { securial_role_assignment: invalid_attributes },
                 headers: @valid_headers,
                 as: :json
        }.not_to change(Securial::RoleAssignment, :count)
      end

      it "renders a JSON response with errors for the new role_assignment" do # rubocop:disable RSpec/PendingWithoutReason
        delete securial.role_assignments_revoke_url,
               params: { securial_role_assignment: invalid_attributes },
               headers: @valid_headers,
               as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      context "when user_id is nil" do
        it "returns an error" do
          delete securial.role_assignments_revoke_url,
                 params: { securial_role_assignment: invalid_attributes },
                 headers: @valid_headers,
                 as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("User not found")
        end
      end

      context "when role_id is nil" do
        let(:invalid_attributes) {
          {
            role_id: nil,
            user_id: securial_user.id,
          }
        }

        it "returns an error" do
          delete securial.role_assignments_revoke_url,
                 params: { securial_role_assignment: invalid_attributes },
                 headers: @valid_headers,
                 as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("Role not found")
        end
      end

      context "when role_id is not a valid role" do
        let(:invalid_attributes) {
          {
            role_id: 9999,
            user_id: securial_user.id,
          }
        }

        it "returns an error" do
          delete securial.role_assignments_revoke_url,
                 params: { securial_role_assignment: invalid_attributes },
                 headers: @valid_headers,
                 as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("Role not found")
        end
      end

      context "when user_id is not a valid user" do
        let(:invalid_attributes) {
          {
            role_id: securial_role.id,
            user_id: 9999,
          }
        }

        it "returns an error" do
          delete securial.role_assignments_revoke_url,
                 params: { securial_role_assignment: invalid_attributes },
                 headers: @valid_headers,
                 as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("User not found")
        end
      end

      context "when role is not already assigned to user" do
        it "returns an error" do
          delete securial.role_assignments_revoke_url,
                 params: { securial_role_assignment: valid_attributes },
                 headers: @valid_headers,
                 as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(JSON.parse(response.body)["error"]).to include("Role is not assigned to user")
        end
      end
    end
  end
end
