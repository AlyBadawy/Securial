json.records @securial_users do |securial_user|
  json.partial! "securial/users/securial_user", securial_user: securial_user
end

json.count @securial_users.count
json.url securial.users_url(format: :json)
