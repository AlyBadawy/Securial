require "rails_helper"

RSpec.describe Securial::Role, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:role_name) }
    it { is_expected.to validate_uniqueness_of(:role_name).case_insensitive  }
  end

  describe "normalization" do
    it "normalizes role_name to title case" do
      role = create(:securial_role, role_name: "super admin")
      expect(role.role_name).to eq("Super Admin")
    end

    it "strips whitespace from role_name" do
      role = create(:securial_role, role_name: "  admin  ")
      expect(role.role_name).to eq("Admin")
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:securial_role)).to be_valid
    end

    it "creates an admin role" do
      role = create(:securial_role, :admin)
      expect(role.role_name).to eq("Admin")
    end

    it "creates a user role" do
      role = create(:securial_role, :user)
      expect(role.role_name).to eq("User")
    end
  end

  describe "Associations" do
    it { is_expected.to have_many(:role_assignments).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:role_assignments) }
  end
end
