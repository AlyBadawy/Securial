FactoryBot.define do
  factory :securial_user, class: "Securial::User" do
    email_address { Faker::Internet.email }
    password { "Password_.1" }
    password_confirmation { "Password_.1" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.cell_phone }
    username { Faker::Internet.username(specifier: 3..20) }
    bio { Faker::Lorem.paragraph }

    trait :admin do
      admin_role = Securial.configuration.admin_role.to_s.strip.titleize
      roles { [Securial::Role.find_or_create_by(role_name: admin_role)] }
    end
  end
end
