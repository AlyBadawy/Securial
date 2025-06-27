# @title Securial Response Headers Middleware
#
# Rack middleware for adding Securial-specific headers to HTTP responses.
#
# This middleware automatically adds identification headers to all HTTP responses
# to indicate that the application is using Securial for authentication and to
# provide developer attribution. These headers can be useful for debugging,
# monitoring, and identifying Securial-powered applications.
#
# @example Adding middleware to Rails application
#   # config/application.rb
#   config.middleware.use Securial::Middleware::ResponseHeaders
#
# @example Response headers added by middleware
#   # HTTP Response Headers:
#   X-Securial-Mounted: true
#   X-Securial-Developer: Aly Badawy - https://alybadawy.com | @alybadawy
#
module Securial
  module Middleware
    # Rack middleware that adds Securial identification headers to responses.
    #
    # This middleware enhances security transparency by clearly identifying
    # when Securial is mounted in an application and provides developer
    # attribution information in response headers.
    #
    class ResponseHeaders
      # Initializes the middleware with the Rack application.
      #
      # @param [#call] app The Rack application to wrap
      #
      # @example
      #   middleware = ResponseHeaders.new(app)
      #
      def initialize(app)
        @app = app
      end

      # Processes the request and adds Securial headers to the response.
      #
      # Calls the wrapped application and then adds identification headers
      # to the response before returning it to the client. The headers
      # provide clear indication of Securial usage and developer attribution.
      #
      # @param [Hash] env The Rack environment hash
      # @return [Array] The Rack response array [status, headers, body] with added headers
      #
      # @example Headers added to response
      #   # Original response headers remain unchanged
      #   # Additional headers added:
      #   # X-Securial-Mounted: "true"
      #   # X-Securial-Developer: "Aly Badawy - https://alybadawy.com | @alybadawy"
      #
      def call(env)
        status, headers, response = @app.call(env)

        # Indicate that Securial is mounted and active
        headers["X-Securial-Mounted"] = "true"

        # Provide developer attribution
        headers["X-Securial-Developer"] = "Aly Badawy - https://alybadawy.com | @alybadawy"

        [status, headers, response]
      end
    end
  end
end
