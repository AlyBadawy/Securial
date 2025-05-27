json.id securial_session.id

json.ip_address securial_session.ip_address
json.user_agent securial_session.user_agent
json.refresh_count securial_session.refresh_count
json.refresh_token securial_session.refresh_token
json.last_refreshed_at securial_session.last_refreshed_at
json.refresh_token_expires_at securial_session.refresh_token_expires_at
json.revoked securial_session.revoked
json.user_id securial_session.user_id

json.partial! "securial/shared/timestamps", record: securial_session

json.url "No URL available for this action"
