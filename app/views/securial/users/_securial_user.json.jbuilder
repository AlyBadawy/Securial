json.id securial_user.id

json.email_address securial_user.email_address
json.username securial_user.username
json.first_name securial_user.first_name
json.last_name securial_user.last_name
json.phone securial_user.phone
json.bio securial_user.bio
json.email_verified securial_user.email_verified
json.locked securial_user.locked
json.locked_at securial_user.locked_at

# json.password_expired securial_user.password_expired?
# This field is currently commented out because it is not required in the JSON response.
# Uncomment this line if the `password_expired` field needs to be included in the future.

json.roles securial_user.roles, partial: "securial/roles/securial_role", as: :securial_role

json.partial! "securial/shared/timestamps", record: securial_user

json.url securial.users_url(securial_user, format: :json)
