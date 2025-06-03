require "rails_helper"

RSpec.describe Securial::RolesController, type: :routing do
  routes { Securial::Engine.routes }

  describe "routing" do
    it "routes to #index" do
      expect(get: "#{Securial.protected_namespace}/roles").to route_to("securial/roles#index", format: :json)
    end

    it "routes to #show" do
      expect(get: "#{Securial.protected_namespace}/roles/1").to route_to("securial/roles#show", id: "1", format: :json)
    end

    it "routes to #create" do
      expect(post: "#{Securial.protected_namespace}/roles").to route_to("securial/roles#create", format: :json)
    end

    it "routes to #update via PUT" do
      expect(put: "#{Securial.protected_namespace}/roles/1").to route_to("securial/roles#update", id: "1", format: :json)
    end

    it "routes to #update via PATCH" do
      expect(patch: "#{Securial.protected_namespace}/roles/1").to route_to("securial/roles#update", id: "1", format: :json)
    end

    it "routes to #destroy" do
      expect(delete: "#{Securial.protected_namespace}/roles/1").to route_to("securial/roles#destroy", id: "1", format: :json)
    end
  end
end