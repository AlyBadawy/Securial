require "rails_helper"

module Securial
  RSpec.describe Identity, type: :request do
    before do
      test_controller = Class.new(ApplicationController) do
        include Identity
        skip_authentication! only: [:admin_no_user]

        before_action :authenticate_admin!, only: [:admin, :admin_no_user]

        def authenticate
          render json: { message: "Success" }
        end

        def current
          render json: { user_id: current_user&.id }
        end

        def admin
          render json: { message: "Admin access granted" }
        end

        def admin_no_user
          # This action is for testing admin access without a user
          render json: { message: "Admin access without user" }
        end
      end

      stub_const("Securial::TestController", test_controller)

      Rails.application.routes.draw do
        mount Securial::Engine => "/securial"
      end

      Engine.routes.draw do
        get "/authenticate", to: "test#authenticate"
        get "/current", to: "test#current"
        get "/admin", to: "test#admin"
        get "/admin_no_user", to: "test#admin_no_user"
      end
    end

    after do
      Engine.routes.clear!
      Rails.application.reload_routes!
    end

    let(:trio) { create_auth_trio }
    let(:securial_user) { trio.first }
    let(:securial_session) { trio.second }
    let(:valid_headers) { auth_headers(token: trio.third) }

    describe "GET /authenticate" do
      context "with a valid token" do
        it "returns a successful response" do
          get "/securial/authenticate", headers: valid_headers, as: :json
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to include("message" => "Success")
        end
      end

      context "with an invalid token" do
        it "returns an unauthorized response" do
          get "/securial/authenticate", headers: { "Authorization" => "Bearer invalid.token" }, as: :json
          expect(response).to have_http_status(:unauthorized)
        end

        it "returns JSON error message of Invalid encoding" do
          get "/securial/authenticate", headers: { "Authorization" => "Bearer invalid token" }, as: :json

          expect(JSON.parse(response.body)["errors"]).to include("You are not signed in")
        end
      end

      context "with a missing token" do
        it "returns an unauthorized response" do
          get "/securial/authenticate", as: :json
          expect(response).to have_http_status(:unauthorized)
        end

        it "returns JSON error message of Missing or invalid Authorization header" do
          get "/securial/authenticate", as: :json
          expect(JSON.parse(response.body)["errors"]).to include("You are not signed in")
        end
      end
    end

    describe 'GET /current' do
      context 'when there is a current session' do
        before do
          allow(Securial::Current).to receive(:session).and_return(securial_session)
        end

        it 'returns the user from the current session' do
          get "/securial/current", as: :json
          expect(controller.current_user).to eq(securial_user)
        end
      end

      context 'when there is no current session' do
        before do
          allow(Securial::Current).to receive(:session).and_return(nil)
        end

        it 'returns nil' do
          get "/securial/current", as: :json
          expect(controller.current_user).to be_nil
        end
      end
    end

    describe "GET /admin" do
      context "when the user is an admin" do
        it "grants admin access" do
          valid_admin_headers = auth_headers(admin: true)
          get "/securial/admin", headers: valid_admin_headers, as: :json
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to include("message" => "Admin access granted")
        end
      end

      context "when the user is not an admin" do
        it "denies admin access" do
          get "/securial/admin", headers: valid_headers, as: :json
            expect(response).not_to have_http_status(:ok)
            expect(response).to have_http_status(:forbidden)
            expect(JSON.parse(response.body)["errors"]).to include("You are not authorized to perform this action")
        end
      end

      context "when the user is not authenticated" do
        it "denies admin access" do
          get "/securial/admin", as: :json
          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)["errors"]).to include("You are not signed in")
        end
      end
    end

    describe "GET /admin_no_user" do
      context "when the user is an admin" do
        it "grants admin access" do
          valid_admin_headers = auth_headers(admin: true)
          get "/securial/admin_no_user", headers: valid_admin_headers, as: :json
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to include("message" => "Admin access without user")
        end
      end

      context "when the user is not an admin" do
        it "denies admin access" do
          get "/securial/admin_no_user", headers: valid_headers, as: :json
            expect(response).not_to have_http_status(:ok)
            expect(response).to have_http_status(:forbidden)
            expect(JSON.parse(response.body)["errors"]).to include("You are not authorized to perform this action")
        end
      end

      context "when the user is not authenticated" do
        it "denies admin access" do
          get "/securial/admin_no_user", as: :json
          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)["errors"]).to include("You are not signed in")
        end
      end
    end


    describe "internal Rails requests" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:info_controller) { Rails::InfoController.new }
      let(:mailers_controller) { Rails::MailersController.new }
      let(:welcome_controller) { Rails::WelcomeController.new }

      before do
        # Mock the controllers to include our Identity concern
        [info_controller, mailers_controller, welcome_controller].each do |controller|
          controller.class.include(described_class)
        end
      end

      it "allows access when controller is Rails::InfoController" do
        allow(Rails::InfoController).to receive(:new).and_return(info_controller)
        expect(info_controller.send(:internal_rails_request?)).to be true
      end

      it "allows access when controller is Rails::MailersController" do
        allow(Rails::MailersController).to receive(:new).and_return(mailers_controller)
        expect(mailers_controller.send(:internal_rails_request?)).to be true
      end

      it "allows access when controller is Rails::WelcomeController" do
        allow(Rails::WelcomeController).to receive(:new).and_return(welcome_controller)
        expect(welcome_controller.send(:internal_rails_request?)).to be true
      end

      it "denies access for regular controllers" do
        regular_controller = TestController.new
        expect(regular_controller.send(:internal_rails_request?)).to be false
      end

      it "handles undefined Rails controllers" do
        hide_const("Rails::InfoController")
        regular_controller = TestController.new
        expect(regular_controller.send(:internal_rails_request?)).to be false
      end
    end

    describe "#authenticate_user!" do
      context "when handling Rails internal paths" do
        before do
          Rails.application.routes.draw do
            mount Securial::Engine => "/securial"
            get '/rails/info' => 'rails/info#properties'
          end
        end

        it "bypasses authentication for Rails internal paths" do
          get "/rails/info"

          expect(response).to have_http_status(:ok)
          expect(response.content_type).to include('text/html')
        end
      end

      context "with a regular path" do
        it "performs authentication checks" do
          get "/securial/authenticate", as: :json

          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)["errors"]).to include("You are not signed in")
        end

        it "allows access with valid authentication" do
          get "/securial/authenticate", headers: valid_headers, as: :json

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to include("message" => "Success")
        end
      end

      context "with incorrect ip or user agent" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        let(:invalid_session) { create(:securial_session, user: securial_user, ip_address: "123.12.12.1", user_agent: "InvalidAgent") }
        let(:invalid_token) { Securial::Auth::AuthEncoder.encode(invalid_session) }
        let(:invalid_headers) { auth_headers(token: invalid_token) }

        it "returns unauthorized when session does not match request" do
          get "/securial/authenticate", headers: invalid_headers, as: :json

          expect(response).to have_http_status(:unauthorized)
          expect(JSON.parse(response.body)["errors"]).to include("You are not signed in")
        end
      end
    end
  end
end
