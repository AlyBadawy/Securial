Rails.application.config.to_prepare do
  class Rack::Attack
    limit = Securial.configuration.rate_limit_requests_per_minute
    resp_status = Securial.configuration.rate_limit_response_status
    resp_message = Securial.configuration.rate_limit_response_message

    ### Throttle login attempts by IP ###
    throttle("securial/logins/ip", limit: limit, period: 1.minute) do |req|
      if req.path.include?("sessions/login") && req.post?
        req.ip
      end
    end

    ### Throttle login attempts by username ###
    throttle("securial/logins/email", limit: 5, period: 1.minute) do |req|
      if req.path.include?("sessions/login") && req.post?
        req.params["email_address"].to_s.downcase.strip
      end
    end

    ### TODO: Add throttling for other endpoints as needed ###
    # Example: Throttle password reset requests by email
    throttle("securial/password_resets/ip", limit: 5, period: 1.minute) do |req|
      if req.path.include?("password/forgot") && req.post?
        req.ip
      end
    end

    throttle("securial/password_resets/email", limit: 5, period: 1.minute) do |req|
      if req.path.include?("password/forgot") && req.post?
        req.params["email_address"].to_s.downcase.strip
      end
    end

    ### Custom response ###
    self.throttled_responder = lambda do |request|
      retry_after = (request.env["rack.attack.match_data"] || {})[:period]
      [
        resp_status,
        {
          "Content-Type" => "application/json",
          "Retry-After" => retry_after.to_s,
        },
        [{ error: resp_message }.to_json]
      ]
    end
  end
end
