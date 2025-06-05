json.records @securial_sessions do |securial_session|
  json.partial! "securial/sessions/session", securial_session: securial_session
end

json.count @securial_sessions.count
json.url "No URL available for this action"
