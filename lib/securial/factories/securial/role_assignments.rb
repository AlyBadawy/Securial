FactoryBot.define do
  factory :securial_role_assignment, class: "Securial::RoleAssignment" do
    association :user, factory: :securial_user
    association :role, factory: :securial_role
  end
end
