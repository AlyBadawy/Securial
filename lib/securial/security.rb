# @title Securial Security Components
#
# Security components and protections for the Securial framework.
#
# This file serves as the entry point for security-related functionality in Securial,
# loading specialized security modules that provide protection mechanisms including
# rate limiting, CSRF protection, and other security measures to safeguard
# Securial-powered applications.
#
# @example Using the rate limiter
#   # Set up a rate limiter for login attempts
#   limiter = Securial::Security::RequestRateLimiter.new(
#     max_requests: 5,
#     period: 1.minute,
#     block_duration: 15.minutes
#   )
#
#   # Check if a request is allowed
#   if limiter.allowed?(request.ip)
#     # Process login attempt
#   else
#     # Return rate limit exceeded response
#   end
#
require "securial/security/request_rate_limiter"

module Securial
  # Namespace for security-related functionality in the Securial framework.
  #
  # The Security module contains components that implement various security
  # measures to protect applications from common attacks and threats:
  #
  # - {RequestRateLimiter} - Protection against brute force and DoS attacks
  # - Additional security components may be added in future versions
  #
  # @see Securial::Security::RequestRateLimiter
  #
  module Security; end
end
