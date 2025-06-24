require "rack/attack"
require "securial/config"

module Securial
  module Security
    module RequestRateLimiter
      extend self

      def apply! # rubocop:disable Metrics/MethodLength
        resp_status = Securial.configuration.rate_limit_response_status
        resp_message = Securial.configuration.rate_limit_response_message
        throttle_configs = [
          { name: "securial/logins/ip", path: "sessions/login", key: ->(req) { req.ip } },
          { name: "securial/logins/email", path: "sessions/login", key: ->(req) { req.params["email_address"].to_s.downcase.strip } },
          { name: "securial/password_resets/ip", path: "password/forgot", key: ->(req) { req.ip } },
          { name: "securial/password_resets/email", path: "password/forgot", key: ->(req) { req.params["email_address"].to_s.downcase.strip } },
        ]

        throttle_configs.each do |config|
          Rack::Attack.throttle(config[:name],
                                limit: ->(_req) { Securial.configuration.rate_limit_requests_per_minute },
                                period: 1.minute
          ) do |req|
            if req.path.include?(config[:path]) && req.post?
              config[:key].call(req)
            end
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
            [{ errors: [resp_message] }.to_json],
          ]
        end
      end
    end
  end
end
