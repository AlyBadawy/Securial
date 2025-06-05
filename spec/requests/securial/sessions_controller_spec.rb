require "rails_helper"

RSpec.describe Securial::SessionsController, type: :request do
  before do
    trio = create_auth_trio
    @signed_in_user, @signed_in_session, @token = trio
    @valid_headers = auth_headers(token: @token)
  end

  describe "GET '/'" do
    it "lists all sessions for the current user" do
      get securial.index_sessions_url, headers: @valid_headers, as: :json
      expect(response).to be_successful
      res_body = JSON.parse(response.body)
      expect(res_body.keys).to match_array(%w[records count url])
      records = res_body["records"]
      expect(records).to be_an_instance_of(Array)
      expect(records.first).to include(
        "id",
        "refresh_count",
        "refresh_token",
        "refresh_token_expires_at",
        "last_refreshed_at",
        "revoked"
      )
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :get, -> { securial.index_sessions_url }, :no_token
      it_behaves_like "unauthorized request", :get, -> { securial.index_sessions_url }, :invalid_token
    end
  end

  describe "GET '/current'" do
    it "shows the session for current session (get session)" do
      get securial.current_session_url, headers: @valid_headers, as: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to include(
        "id",
        "refresh_count",
        "refresh_token",
        "refresh_token_expires_at",
        "last_refreshed_at",
        "revoked"
      )
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :get, -> { securial.current_session_url }, :no_token
      it_behaves_like "unauthorized request", :get, -> { securial.current_session_url }, :invalid_token
    end
  end

  describe "GET '/id/:id'" do
    let(:new_session) { create(:securial_session, user: @signed_in_user) }

    it "shows the session for a given ID (get sessions/:id)" do
      get securial.session_url(new_session), headers: @valid_headers, as: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body)).to include(
        "id",
        "refresh_count",
        "refresh_token",
        "refresh_token_expires_at",
        "last_refreshed_at",
        "revoked"
      )
    end

    it "shows 404 not found for the wrong session ID (get sessions/:id)" do
      get securial.session_url("wrong"), headers: @valid_headers, as: :json
      expect(response).not_to be_successful
      expect(response).to have_http_status(:not_found)
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :get, -> { securial.session_url(new_session) }, :no_token
      it_behaves_like "unauthorized request", :get, -> { securial.session_url(new_session) }, :invalid_token
    end
  end

  describe "POST '/login'" do
    let(:new_user) { create(:securial_user, password: "MyNewPassword!1", password_confirmation: "MyNewPassword!1") }
    let(:new_session) { create(:securial_session, user: new_user) }
    let(:new_valid_headers) {
      token = Securial::Auth::AuthEncoder.encode(new_session)
      { "Authorization" => "Bearer #{token}" }
    }
    let(:valid_attributes) {
      { email_address: new_user.email_address, password: "MyNewPassword!1" }
    }

    let(:invalid_attributes) {
      { email_address: new_user.email_address, password: "wrong_password" }
    }

    context "with valid parameters" do
      context "when password is not yet expired" do
        it "signs in the user and returns tokens" do
          headers = { "User-Agent" => "RSpec" }
          post securial.login_url, params: valid_attributes, headers: headers, as: :json
          expect(response).to have_http_status(:created)
          expect(response.content_type).to match(a_string_including("application/json"))
          expect(response.body).to include(
            "access_token",
            "refresh_token",
            "refresh_token_expires_at"
          )
        end
      end

      context "when password is expired" do
        it "returns 403 forbidden and instructions to reset password" do
          new_user.update!(password_changed_at: 10.years.ago)
          headers = { "User-Agent" => "RSpec" }
          post securial.login_url, params: valid_attributes, headers: headers, as: :json
          expect(response).to have_http_status(:forbidden)
          expect(response.content_type).to match(a_string_including("application/json"))
          json_response = JSON.parse(response.body)
          expect(json_response).to include(
            "error" => "Password expired",
            "instructions" => "Please reset your password before logging in."
          )
        end
      end
    end

    context "with invalid parameters" do
      it "returns unauthorized status" do
        headers = { "User-Agent" => "RSpec" }
        post securial.login_url, params: invalid_attributes, headers: headers, as: :json
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(response.body).to include("error")
      end
    end
  end

  describe "DELETE '/logout'" do
    context "when user is signed in" do
      it "logs out the current user" do
        Securial::Current.session = @signed_in_session
        expect(Securial::Current.session).not_to be_nil
        delete securial.logout_url, headers: @valid_headers, as: :json
        expect(Securial::Current.session).to be_nil
      end

      it "returns 204 no content" do
        Securial::Current.session = @signed_in_session
        expect(Securial::Current.session).not_to be_nil
        delete securial.logout_url, headers: @valid_headers, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :delete, -> { securial.logout_url }, :no_token
      it_behaves_like "unauthorized request", :delete, -> { securial.logout_url }, :invalid_token
    end
  end

  describe "PUT /refresh" do
    it "refreshes the session" do
      Securial::Current.session = @signed_in_session
      expect(Securial::Current.session).not_to be_nil
      put securial.refresh_session_url, params: { refresh_token: @signed_in_session.refresh_token }, headers: @valid_headers, as: :json
      expect(response).to have_http_status(:created)
      expect(response.content_type).to match(a_string_including("application/json"))
      expect(response.body).to include(
        "access_token",
        "refresh_token",
        "refresh_token_expires_at"
      )
    end

    it "returns 422 unprocessable entity when session is invalid" do
      Securial::Current.session = @signed_in_session
      Securial::Current.session.revoke!
      put securial.refresh_session_url, params: { refresh_token: @signed_in_session.refresh_token }, headers: @valid_headers, as: :json
      expect(response).not_to be_successful
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 422 unprocessable entity when refresh_token is invalid" do
      Securial::Current.session = @signed_in_session
      expect(Securial::Current.session).not_to be_nil
      put securial.refresh_session_url, params: { refresh_token: "invalid" }, headers: @valid_headers, as: :json
      expect(response).not_to be_successful
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /id/:id/revoke" do
    it "revokes a session by ID" do
      new_session = create(:securial_session, user: @signed_in_user)
      expect(new_session).not_to be_nil
      delete securial.revoke_session_by_id_url(new_session), headers: @valid_headers, as: :json
      expect(response).to have_http_status(:no_content)
      expect(Securial::Session.find_by(id: new_session.id)).to be_revoked
    end

    it "returns 404 not found when session ID is invalid" do
      delete securial.revoke_session_by_id_url(id: "invalid"), headers: @valid_headers, as: :json
      expect(response).not_to be_successful
      expect(response).to have_http_status(:not_found)
    end

    it "clears the current session if it is revoked" do
      Securial::Current.session = @signed_in_session
      expect(Securial::Current.session).not_to be_nil
      delete securial.revoke_session_by_id_url(@signed_in_session), headers: @valid_headers, as: :json
      expect(response).to have_http_status(:no_content)
      expect(Securial::Current.session).to be_nil
    end

    it "does not clear the current session if a different session is revoked" do
      Securial::Current.session = @signed_in_session
      expect(Securial::Current.session).not_to be_nil
      new_session = create(:securial_session, user: @signed_in_user)
      delete securial.revoke_session_by_id_url(new_session), headers: @valid_headers, as: :json
      expect(response).to have_http_status(:no_content)
      expect(@signed_in_session.reload).not_to be_revoked
      expect(new_session.reload).to be_revoked
    end

    describe "unauthorized access" do
      let(:new_session) { create(:securial_session, user: @signed_in_user) }

      it_behaves_like "unauthorized request", :delete, -> { securial.revoke_session_by_id_url(new_session) }, :no_token
      it_behaves_like "unauthorized request", :delete, -> { securial.revoke_session_by_id_url(new_session) }, :invalid_token
    end
  end

  describe "DELETE /revoke_all" do
    context "when user is signed in" do
      it "revokes all sessions for the current user" do
        Securial::Current.session = @signed_in_session
        expect(Securial::Current.session).not_to be_nil
        delete securial.revoke_all_sessions_url, headers: @valid_headers, as: :json
        expect(Securial::Current.session).to be_nil
      end

      it "returns 204 no content" do
        Securial::Current.session = @signed_in_session
        expect(Securial::Current.session).not_to be_nil
        delete securial.revoke_all_sessions_url, headers: @valid_headers, as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    describe "unauthorized access" do
      it_behaves_like "unauthorized request", :delete, -> { securial.revoke_all_sessions_url }, :no_token
      it_behaves_like "unauthorized request", :delete, -> { securial.revoke_all_sessions_url }, :invalid_token
    end
  end
end
