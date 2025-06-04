FactoryBot.define do
  factory :securial_session, class: "Securial::Session" do
    ip_address { "127.0.0.1" }
    user_agent { "Ruby/RSpec" }
    refresh_count { 1 }
    refresh_token { SecureRandom.hex(64) }
    last_refreshed_at { Time.current }
    refresh_token_expires_at { 1.week.from_now }
    revoked { false }
    association :user, factory: :securial_user
  end
end
