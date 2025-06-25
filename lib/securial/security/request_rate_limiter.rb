# @title Securial Request Rate Limiter
#
# Rate limiting middleware for protecting authentication endpoints in the Securial framework.
#
# This file implements rate limiting for sensitive endpoints like login and password reset,
# protecting them from brute force attacks, credential stuffing, and denial of service attempts.
# It uses the Rack::Attack middleware to track and limit request rates based on IP address
# and provided credentials.
#
# @example Basic configuration in a Rails initializer
#   # In config/initializers/securial.rb
#   Securial.configure do |config|
#     config.rate_limit_requests_per_minute = 5
#     config.rate_limit_response_status = 429
#     config.rate_limit_response_message = "Too many requests. Please try again later."
#   end
#
#   # Apply rate limiting
#   Securial::Security::RequestRateLimiter.apply!
#
require "rack/attack"
require "securial/config"

module Securial
  module Security
    # Protects authentication endpoints with configurable rate limiting.
    #
    # This module provides Rack::Attack-based rate limiting for sensitive Securial
    # endpoints, preventing brute force attacks and abuse. It limits requests based
    # on both IP address and credential values (like email address), providing
    # multi-dimensional protection against different attack vectors.
    #
    # Protected endpoints include:
    # - Login attempts (/sessions/login)
    # - Password reset requests (/password/forgot)
    #
    module RequestRateLimiter
      extend self

      # Applies rate limiting rules to the Rack::Attack middleware.
      #
      # This method configures Rack::Attack with throttling rules for sensitive endpoints
      # and sets up a custom JSON response format for throttled requests. It should be
      # called during application initialization, typically in a Rails initializer.
      #
      # Rate limits are defined using settings from the Securial configuration:
      # - rate_limit_requests_per_minute: Maximum requests allowed per minute
      # - rate_limit_response_status: HTTP status code to return (typically 429)
      # - rate_limit_response_message: Message to include in throttled responses
      #
      # @return [void]
      # @see Securial::Config::Configuration
      # @see Rack::Attack
      #
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
