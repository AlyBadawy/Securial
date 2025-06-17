json.status "ok"
json.timestamp Time.current
json.version Securial::VERSION if @current_user&.admin?
json.current_user do
  if @current_user
    json.extract! @current_user, :id, :email, :name, :is_admin
  else
    json.null!
  end
end
