json.id securial_role.id

json.role_name securial_role.role_name
json.hide_from_profile securial_role.hide_from_profile

json.partial! "securial/shared/timestamps", record: securial_role

json.url securial.roles_url(securial_role, format: :json)
