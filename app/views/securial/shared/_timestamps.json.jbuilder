if Securial.configuration.timestamps_in_response == :all ||
  (
    Securial.configuration.timestamps_in_response == :admins_only &&
    current_user&.admin?
  )
    json.created_at record.created_at if record.respond_to?(:created_at)
    json.updated_at record.updated_at if record.respond_to?(:updated_at)
end
