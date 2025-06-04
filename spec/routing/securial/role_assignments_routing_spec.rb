require "rails_helper"

RSpec.describe Securial::RoleAssignmentsController, type: :routing do
  routes { Securial::Engine.routes }

  describe "routing" do
    it "routes to #create" do
      expect(post: "#{Securial.protected_namespace}/role_assignments/assign").to route_to("securial/role_assignments#create", format: :json)
    end

    it "routes to #destroy" do
      expect(delete: "#{Securial.protected_namespace}/role_assignments/revoke").to route_to("securial/role_assignments#destroy", format: :json)
    end
  end
end
