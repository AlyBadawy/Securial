require "rails_helper"

RSpec.describe Securial::SessionsController, type: :routing do
  routes { Securial::Engine.routes }

  describe "routing" do
    it "routes to GET '/sessions' to get all sessions of current user" do
      expect(get: "/sessions").to route_to("securial/sessions#index", format: :json)
    end

    it "routes to GET '/sessions/current' to get current session" do
      expect(get: "/sessions/current").to route_to("securial/sessions#show", format: :json)
    end

    it "routes to GET '/sessions/id/123' to get session by ID" do
      expect(get: "/sessions/id/123").to route_to("securial/sessions#show", format: :json, id: "123")
    end

    it "routes to POST '/sessions/login' to login" do
      expect(post: "/sessions/login").to route_to("securial/sessions#login", format: :json)
    end

    it "routes to DELETE '/sessions/logout' to logout the user" do
      expect(delete: "/sessions/logout").to route_to("securial/sessions#logout", format: :json)
    end

    it "routes to PUT '/sessions/refresh' to refresh the session" do
      expect(put: "/sessions/refresh").to route_to("securial/sessions#refresh", format: :json)
    end

    it "routes to DELETE '/sessions/id/1/revoke' to revoke a session by ID" do
      expect(delete: "/sessions/id/1/revoke").to route_to("securial/sessions#revoke", format: :json, id: "1")
    end

    it "routes to DELETE '/sessions/revoke_all' to revoke all sessions of current user" do
      expect(delete: "/sessions/revoke_all").to route_to("securial/sessions#revoke_all", format: :json)
    end
  end
end
