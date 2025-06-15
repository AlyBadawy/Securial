require "rack/attack"
require "securial/config"
require "securial/logger"

module Securial
  module Security
    module RequestRateLimiter
      module_function

      def apply! # rubocop:disable Metrics/MethodLength
        resp_status = Securial.configuration.rate_limit_response_status
        resp_message = Securial.configuration.rate_limit_response_message
        # Throttle login attempts by IP
        Rack::Attack.throttle("securial/logins/ip",
                              limit: ->(_req) { Securial.configuration.rate_limit_requests_per_minute },
                              period: 1.minute
        ) do |req|
          if req.path.include?("sessions/login") && req.post?
            req.ip
          end
        end

        # Throttle login attempts by username/email
        Rack::Attack.throttle("securial/logins/email",
                              limit: ->(_req) { Securial.configuration.rate_limit_requests_per_minute },
                              period: 1.minute
        ) do |req|
          if req.path.include?("sessions/login") && req.post?
            req.params["email_address"].to_s.downcase.strip
          end
        end

        # Throttle password reset requests by IP
        Rack::Attack.throttle("securial/password_resets/ip",
                              limit: ->(_req) { Securial.configuration.rate_limit_requests_per_minute },
                              period: 1.minute
        ) do |req|
          if req.path.include?("password/forgot") && req.post?
            req.ip
          end
        end

        # Throttle password reset requests by email
        Rack::Attack.throttle("securial/password_resets/email",
                              limit: ->(_req) { Securial.configuration.rate_limit_requests_per_minute },
                              period: 1.minute
        ) do |req|
          if req.path.include?("password/forgot") && req.post?
            req.params["email_address"].to_s.downcase.strip
          end
        end

        # Custom response for throttled requests
        Rack::Attack.throttled_responder = lambda do |request|
          retry_after = (request.env["rack.attack.match_data"] || {})[:period]
          [
            resp_status,
            {
              "Content-Type" => "application/json",
              "Retry-After" => retry_after.to_s,
            },
            [{ error: resp_message }.to_json],
          ]
        end
      end
    end
  end
end
