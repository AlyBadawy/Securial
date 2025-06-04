require "rails_helper"

module Securial
  RSpec.describe Helpers::RolesHelper, type: :helper do
    before do
      allow(Securial.configuration).to receive(:admin_role).and_return("SuperAdmin")
    end

    describe ".protected_namespace" do
      it "returns the protected namespace pluralized and lowercase" do
        expect(described_class.protected_namespace).to eq("super_admins")
      end
    end

    describe ".titleized_admin_role" do
      it "returns the admin role titleized" do
        expect(described_class.titleized_admin_role).to eq("Super Admin")
      end
    end
  end
end
