require "rails_helper"

module Securial
  RSpec.describe RoleAssignment, type: :model do
    describe "factory" do
      it "has a valid factory" do
        expect(build(:securial_role_assignment)).to be_valid
      end
    end

    describe "Associations" do
      it { is_expected.to belong_to(:role) }
      it { is_expected.to belong_to(:user) }
    end
  end
end
