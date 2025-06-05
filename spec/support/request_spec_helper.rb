module RequestSpecHelper
  def create_auth_trio(user: nil, admin: false)
    user ||= (admin ? FactoryBot.create(:securial_user, :admin) : FactoryBot.create(:securial_user))
    session = FactoryBot.create(:securial_session, user: user)
    token = Securial::Auth::AuthEncoder.encode(session)
    [user, session, token]
  end

  def auth_headers(token: nil, user: nil, admin: false, extra_headers: {})
    auth_token = "Bearer #{token ? token : create_auth_trio(user: user, admin: admin).third}"
      {
        'Accept' => 'application/json',
        'Authorization' => auth_token,
        'Content-Type' => 'application/json',
        "User-Agent" => "Ruby/RSpec",
      }.merge(extra_headers)
  end

  def admin_auth_headers(extra_headers: {})
    auth_headers(admin: true, extra_headers: extra_headers)
  end
end
