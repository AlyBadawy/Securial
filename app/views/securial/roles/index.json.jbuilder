json.records @securial_roles do |securial_role|
  json.partial! "securial/roles/securial_role", securial_role: securial_role
end

json.count @securial_roles.count
json.url securial.roles_url(format: :json)

