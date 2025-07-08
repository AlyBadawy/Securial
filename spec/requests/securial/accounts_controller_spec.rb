require "rails_helper"

RSpec.describe Securial::AccountsController, type: :request do
  let(:valid_attributes) {
    {
      email_address: "test@example.com",
      password: "passw0rD1!",
      password_confirmation: "passw0rD1!",
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
    %w[id first_name last_name phone username bio roles created_at updated_at url]
  }

  before do
    @signed_in_user = create(:securial_user)
    @valid_headers = auth_headers(user: @signed_in_user)
  end


  describe "/accounts" do
    describe "GET '/me'" do
      context "when user is logged in" do
        it "returns a successful response" do
          get securial.me_url, headers: @valid_headers
          expect(response).to have_http_status(:ok)
        end

        it "returns a JSON response with the correct keys" do
          get securial.me_url, headers: @valid_headers
          expect(response.content_type).to match(a_string_including("application/json"))
          res_body = JSON.parse(response.body)

          expect(res_body.keys).to include(*expected_keys)
        end

        it "returns the current user" do
          get securial.me_url, headers: @valid_headers
          res_body = JSON.parse(response.body)
          expect(res_body.keys).to include(*expected_keys)
          expect(res_body["username"]).to eq(@signed_in_user.username)
          expect(res_body["roles"]).to be_an(Array)
          expect(res_body["roles"].length).to eq(0)
        end
      end

      describe "unauthorized access" do
        it_behaves_like "unauthorized request", :get, -> { securial.me_url }, :no_token
        it_behaves_like "unauthorized request", :get, -> { securial.me_url }, :invalid_token
      end
    end

    describe "GET 'profile/:username'" do
      context "when profiles are enabled" do
        before do
          Securial.configuration.enable_other_profiles = true
        end

        after do
          Securial.configuration.enable_other_profiles = false
        end

        context "when username exists" do
          it "renders a successful response" do
            create(:securial_user, username: "testUser")
            get securial.profile_by_username_url("testUser"), as: :json, headers: @valid_headers
            expect(response.content_type).to match(a_string_including("application/json"))
            expect(response).to be_successful
          end

          it "renders a JSON response with the correct keys" do
            create(:securial_user, username: "testUser1")
            get securial.profile_by_username_url("testUser1"), as: :json, headers: @valid_headers
            res_body = JSON.parse(response.body)

            expect(res_body.keys).to include(*expected_keys)
          end

          it "renders the user profile" do
            create(:securial_user, username: "testUser2")
            get securial.profile_by_username_url("testUser2"), as: :json, headers: @valid_headers
            res_body = JSON.parse(response.body)
            expect(res_body["username"]).to eq("testUser2")
            expect(res_body["roles"]).to be_an(Array)
            expect(res_body["roles"].length).to eq(0)
          end
        end

        context "when username does not exist" do
          let(:username) { "non_existent_username" }

          it "renders a not found response" do
            get securial.profile_by_username_url(username), as: :json, headers: @valid_headers
            expect(response).to have_http_status(:not_found)
          end

          it "renders an error message" do
            get securial.profile_by_username_url(username), as: :json, headers: @valid_headers
            expect(response.content_type).to match(a_string_including("application/json"))
            res_body = JSON.parse(response.body)
            expect(res_body["errors"]).to include("User not found")
          end

          it "does not render the user profile" do
            get securial.profile_by_username_url(username), as: :json, headers: @valid_headers
            expect(response.content_type).to match(a_string_including("application/json"))
            res_body = JSON.parse(response.body)
            expected_keys = ["errors"]
            expect(res_body.keys).to include(*expected_keys)
            expect(res_body["errors"]).to include("User not found")
          end
        end

        describe "unauthorized access" do
          before do
            create(:securial_user, username: "testUser3")
          end

          it_behaves_like "unauthorized request", :get, -> { securial.profile_by_username_url("testUser3") }, :no_token
          it_behaves_like "unauthorized request", :get, -> { securial.profile_by_username_url("testUser3") }, :invalid_token
        end
      end

      context "when profiles are disabled" do
        before do
          Securial.configuration.enable_other_profiles = false
        end

        it "returns a forbidden response" do
          get securial.profile_by_username_url("testUser4"), as: :json, headers: @valid_headers
          expect(response).to have_http_status(:forbidden)
        end

        it "renders an error message" do
          get securial.profile_by_username_url("testUser4"), as: :json, headers: @valid_headers
          expect(response.content_type).to match(a_string_including("application/json"))
          res_body = JSON.parse(response.body)
          expect(res_body["errors"]).to include("User profiles are not enabled")
        end
      end
    end

    describe "POST /register" do
      context "with valid parameters" do
        it "creates a new User" do
          expect {
            post securial.register_url,
                 params: { securial_user: valid_attributes }, headers: @valid_headers, as: :json
          }.to change(Securial::User, :count).by(1)
        end

        it "renders a JSON response with the new user" do
          post securial.register_url,
               params: { securial_user: valid_attributes }, headers: @valid_headers, as: :json
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including("application/json"))
          res_body = JSON.parse(response.body)

          expect(res_body.keys).to include(*expected_keys)
        end
      end

      context "with invalid parameters" do
        it "does not create a new User" do
          expect {
            post securial.register_url,
                 params: { securial_user: invalid_attributes }, as: :json
          }.not_to change(Securial::User, :count)
        end

        it "renders a JSON response with errors for the new user" do
          post securial.register_url,
               params: { securial_user: invalid_attributes }, headers: @valid_headers, as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
        end
      end
    end

    describe "PUT '/update'" do
      context "with a valid current password" do
        context "with valid parameters" do
          it "updates the requested user" do
            put securial.update_profile_url,
                params: {
                  securial_user: {
                    current_password: "Password_.1",
                    first_name: "Updated",
                    last_name: "One",
                  },
                },
                headers: @valid_headers,
                as: :json
            @signed_in_user.reload
            expect(@signed_in_user.first_name).to eq("Updated")
            expect(@signed_in_user.last_name).to eq("One")
          end

          it "renders a JSON response with the updated user" do
            put securial.update_profile_url,
                params: {
                  securial_user: {
                    current_password: "Password_.1",
                    first_name: "Updated",
                    last_name: "Two",
                  },
                },
                headers: @valid_headers,
                as: :json
            expect(response).to have_http_status(:ok)
            expect(response.content_type).to match(a_string_including("application/json"))
          end

          it "returns the updated user" do
            put securial.update_profile_url,
                params: {
                  securial_user: {
                    current_password: "Password_.1",
                    first_name: "Updated",
                    last_name: "Three",
                  },
                },
                headers: @valid_headers,
                as: :json
            res_body = JSON.parse(response.body)
            expect(res_body.keys).to include(*expected_keys)
            expect(res_body["first_name"]).to eq("Updated")
            expect(res_body["last_name"]).to eq("Three")
          end
        end

        context "with invalid parameters" do
          it "renders a JSON response with errors for the user" do
            put securial.update_profile_url,
                params: {
                  securial_user: {
                    current_password: "Password_.1",
                    first_name: nil,
                    last_name: nil,
                  },
                },
                headers: @valid_headers,
                as: :json
            expect(response).to have_http_status(:unprocessable_entity)
            expect(response.content_type).to match(a_string_including("application/json"))
            res_body = JSON.parse(response.body)
            expect(res_body["errors"]).to include("First name can't be blank", "Last name can't be blank")
          end

          it "does not update the user" do
            put securial.update_profile_url,
                params: {
                  securial_user: {
                    current_password: "Password_.1",
                    first_name: nil,
                    last_name: nil,
                  },
                },
                headers: @valid_headers,
                as: :json
            @signed_in_user.reload
            expect(@signed_in_user.first_name).not_to be_nil
            expect(@signed_in_user.last_name).not_to be_nil
          end
        end
      end

      context "with invalid current password" do
        it "renders a JSON response with an error message" do
          put securial.update_profile_url,
              params: {
                securial_user: {
                  current_password: "wrong_password",
                  first_name: "Updated",
                },
              },
              headers: @valid_headers,
              as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          res_body = JSON.parse(response.body)
          expect(res_body["errors"]).to include("Current password is incorrect")
        end

        it "does not update the user" do
          put securial.update_profile_url,
              params: {
                securial_user: {
                  current_password: "wrong_password",
                  first_name: "Updated",
                },
              },
              headers: @valid_headers,
              as: :json
          @signed_in_user.reload
          expect(@signed_in_user.first_name).not_to eq("Updated")
        end
      end

      describe "unauthorized access" do
        let(:new_attributes) {
          { securial_user: {
              current_password: "Password_.1",
              first_name: "Updated",
              last_name: "Three",
            },
          }
        }

        it_behaves_like "unauthorized request", :put, -> { securial.update_profile_url }, :no_token, -> { new_attributes }
        it_behaves_like "unauthorized request", :put, -> { securial.update_profile_url }, :invalid_token, -> { new_attributes }
      end
    end

    describe "Delete '/delete_account'" do
      context "with valid current password" do
        it "deletes the user" do
          expect {
            delete securial.delete_account_url,
                   params: {
                     securial_user: {
                       current_password: "Password_.1",
                     },
                   },
                   headers: @valid_headers,
                   as: :json
          }.to change(Securial::User, :count).by(-1)
        end

        it "renders a JSON response with a success message" do
          delete securial.delete_account_url,
                 params: {
                      securial_user: {
                        current_password: "Password_.1",
                      },
                    },
                 headers: @valid_headers,
                 as: :json
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to match(a_string_including("application/json"))
          res_body = JSON.parse(response.body)
          expect(res_body["message"]).to eq("Account deleted successfully")
        end
      end

      context "with invalid current password" do
        it "renders a JSON response with an error message" do
          delete securial.delete_account_url,
                 params: {
                   securial_user: {
                     current_password: "wrong_password",
                   },
                 },
                 headers: @valid_headers,
                 as: :json
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.content_type).to match(a_string_including("application/json"))
          res_body = JSON.parse(response.body)
          expect(res_body["errors"]).to include("Current password is incorrect")
        end

        it "does not delete the user" do
          expect {
            delete securial.delete_account_url,
                   params: {
                     securial_user: {
                       current_password: "wrong_password",
                     },
                   },
                   headers: @valid_headers,
                   as: :json
          }.not_to change(Securial::User, :count)
        end
      end

      describe "unauthorized access" do
        it_behaves_like "unauthorized request", :delete, -> { securial.delete_account_url }, :no_token, -> { {
          securial_user: {
            current_password: "Password_.1",
          },
        } }
        it_behaves_like "unauthorized request", :delete, -> { securial.delete_account_url }, :invalid_token, -> { {
          securial_user: {
            current_password: "Password_.1",
          },
        } }
      end
    end
  end
end
