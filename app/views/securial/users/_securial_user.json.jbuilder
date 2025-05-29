json.id securial_user.id

json.first_name securial_user.first_name
json.last_name securial_user.last_name
json.phone securial_user.phone
json.username securial_user.username
json.bio securial_user.bio

json.password_expired securial_user.password_expired?

json.roles securial_user.roles, partial: "securial/roles/securial_role", as: :securial_role

json.partial! "securial/shared/timestamps", record: securial_user

json.url securial.user_url(securial_user, format: :json)
