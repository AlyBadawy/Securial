require "rails_helper"

RSpec.describe Securial::AccountsController, type: :routing do
  routes { Securial::Engine.routes }

  describe "routing" do
    it "routes to GET '/accounts/me' for current user account" do
      expect(get: "/accounts/me").to route_to("securial/accounts#me", format: :json)
    end

    it "routes to GET '/profiles/cool_user' to get user profile by username" do
      Securial.configuration.enable_other_profiles = true
      Rails.application.reload_routes!
      expect(get: "/profiles/cool_user").to route_to("securial/accounts#show", username: "cool_user", format: :json)

      Securial.configuration.enable_other_profiles = false
      Rails.application.reload_routes!
      expect(get: "/profiles/cool_user").not_to be_routable
    end

    it "routes to POST '/accounts/register' to register a new account" do
      expect(post: "/accounts/register").to route_to("securial/accounts#register", format: :json)
    end

    it "routes to PUT '/accounts/update' to update current user's profile" do
      expect(put: "/accounts/update").to route_to("securial/accounts#update_profile", format: :json)
    end

    it "routes to DELETE '/accounts/delete_account' to delete current user's account" do
      expect(delete: "/accounts/delete_account").to route_to("securial/accounts#delete_account", format: :json)
    end
  end
end
