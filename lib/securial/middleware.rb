# @title Securial Middleware Components
#
# Rack middleware components for the Securial framework.
#
# This file serves as the entry point for middleware-related functionality in Securial,
# loading specialized middleware classes that provide features like request/response
# processing, logging enhancements, and security header management.
#
require "securial/middleware/request_tag_logger"
require "securial/middleware/transform_request_keys"
require "securial/middleware/transform_response_keys"
require "securial/middleware/response_headers"

module Securial
  # Namespace for Rack middleware components in the Securial framework.
  #
  # This module contains several middleware components that enhance Rails applications:
  #
  # - {RequestTagLogger} - Tags logs with request IDs for better traceability
  # - {TransformRequestKeys} - Transforms incoming request parameter keys to a consistent format
  # - {TransformResponseKeys} - Transforms outgoing response JSON keys to match client conventions
  # - {ResponseHeaders} - Adds security headers to responses based on configuration
  #
  # @example Using middleware in a Rails application (config/application.rb)
  #   module YourApp
  #     class Application < Rails::Application
  #       # Add request logging with unique IDs
  #       config.middleware.use Securial::Middleware::RequestTagLogger
  #
  #       # Transform request keys from camelCase to snake_case
  #       config.middleware.use Securial::Middleware::TransformRequestKeys
  #
  #       # Transform response keys from snake_case to camelCase
  #       config.middleware.use Securial::Middleware::TransformResponseKeys
  #
  #       # Add security headers to all responses
  #       config.middleware.use Securial::Middleware::ResponseHeaders
  #     end
  #   end
  #
  # @see Securial::Middleware::RequestTagLogger
  # @see Securial::Middleware::TransformRequestKeys
  # @see Securial::Middleware::TransformResponseKeys
  # @see Securial::Middleware::ResponseHeaders
  #
  module Middleware; end
end
