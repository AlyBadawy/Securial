json.status "ok"
json.timestamp Time.current
json.version Securial::VERSION if @current_user&.is_admin?
