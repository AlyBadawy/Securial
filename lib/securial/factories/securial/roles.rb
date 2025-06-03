FactoryBot.define do
  factory :securial_role, class: "Securial::Role" do
    role_name { "MyString" }
    hide_from_profile { false }

    trait :admin do
      role_name { "Admin" }
    end

    trait :user do
      role_name { "User" }
    end

    trait :hidden do
      hide_from_profile { true }
    end
  end
end
