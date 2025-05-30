require "rails_helper"

RSpec.describe Securial::SessionsController, type: :routing do
  let(:default_format) { :json }

  describe "routing" do
    it "routes to GET '/securial/sessions' to get all sessions of current user" do
      expect(get: "/securial/sessions").to route_to("securial/sessions#index", format: default_format)
    end

    it "routes to GET '/securial/sessions/current' to get current session" do
      expect(get: "/securial/sessions/current").to route_to("securial/sessions#show", format: default_format)
    end

    it "routes to GET '/securial/sessions/id/123' to get session by ID" do
      expect(get: "/securial/sessions/id/123").to route_to("securial/sessions#show", format: default_format, id: "123")
    end

    it "routes to POST '/securial/sessions/login' to login" do
      expect(post: "/securial/sessions/login").to route_to("securial/sessions#login", format: default_format)
    end

    it "routes to DELETE '/securial/sessions/logout' to logout the user" do
      expect(delete: "/securial/sessions/logout").to route_to("securial/sessions#logout", format: default_format)
    end

    it "routes to PUT '/securial/sessions/refresh' to refresh the session" do
      expect(put: "/securial/sessions/refresh").to route_to("securial/sessions#refresh", format: default_format)
    end

    it "routes to DELETE '/securial/sessions/id/1/revoke' to revoke a session by ID" do
      expect(delete: "/securial/sessions/id/1/revoke").to route_to("securial/sessions#revoke", format: default_format, id: "1")
    end

    it "routes to DELETE '/securial/sessions/revoke_all' to revoke all sessions of current user" do
      expect(delete: "/securial/sessions/revoke_all").to route_to("securial/sessions#revoke_all", format: default_format)
    end
  end
end
