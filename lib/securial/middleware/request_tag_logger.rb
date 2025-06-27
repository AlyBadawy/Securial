# @title Securial Request Tag Logger Middleware
#
# Rack middleware for adding request context to log messages.
#
# This middleware automatically tags all log messages within a request with
# contextual information like request ID, IP address, and user agent. This
# enables better tracking and debugging of requests across the application
# by providing consistent context in all log entries.
#
# @example Adding middleware to Rails application
#   # config/application.rb
#   config.middleware.use Securial::Middleware::RequestTagLogger
#
# @example Log output with request tags
#   # Without middleware:
#   [2024-06-27 10:30:15] INFO  -- User authentication successful
#
#   # With middleware:
#   [2024-06-27 10:30:15] INFO  -- [abc123-def456] [IP:192.168.1.100] [UA:Mozilla/5.0...] User authentication successful
#
module Securial
  module Middleware
    # Rack middleware that adds request context tags to log messages.
    #
    # This middleware intercepts requests and wraps the application call
    # with tagged logging, ensuring all log messages generated during
    # request processing include relevant request metadata for better
    # traceability and debugging.
    #
    class RequestTagLogger
      # Initializes the middleware with the Rack application and logger.
      #
      # @param [#call] app The Rack application to wrap
      # @param [Logger] logger The logger instance to use for tagging (defaults to Securial.logger)
      #
      # @example
      #   middleware = RequestTagLogger.new(app, Rails.logger)
      #
      def initialize(app, logger = Securial.logger)
        @app = app
        @logger = logger
      end

      # Processes the request with tagged logging context.
      #
      # Extracts request metadata from the Rack environment and applies
      # them as tags to all log messages generated during the request
      # processing. Tags are automatically removed after the request completes.
      #
      # @param [Hash] env The Rack environment hash
      # @return [Array] The Rack response array [status, headers, body]
      #
      # @example Request processing with tags
      #   # All log messages during this request will include:
      #   # - Request ID (if available)
      #   # - IP address (if available)
      #   # - User agent (if available)
      #   response = middleware.call(env)
      #
      def call(env)
        request_id = request_id_from_env(env)
        ip_address = ip_from_env(env)
        user_agent = user_agent_from_env(env)

        tags = []
        tags << request_id if request_id
        tags << "IP:#{ip_address}" if ip_address
        tags << "UA:#{user_agent}" if user_agent

        @logger.tagged(*tags) do
          @app.call(env)
        end
      end

      private

      # Extracts the request ID from the Rack environment.
      #
      # Looks for request ID in ActionDispatch's request_id or the
      # X-Request-ID header, providing request traceability across
      # multiple services and log aggregation systems.
      #
      # @param [Hash] env The Rack environment hash
      # @return [String, nil] The request ID if found, nil otherwise
      # @api private
      #
      def request_id_from_env(env)
        env["action_dispatch.request_id"] || env["HTTP_X_REQUEST_ID"]
      end

      # Extracts the client IP address from the Rack environment.
      #
      # Prioritizes ActionDispatch's processed remote IP (which handles
      # proxy headers) over the raw REMOTE_ADDR to ensure accurate
      # client identification behind load balancers and proxies.
      #
      # @param [Hash] env The Rack environment hash
      # @return [String, nil] The client IP address if found, nil otherwise
      # @api private
      #
      def ip_from_env(env)
        env["action_dispatch.remote_ip"]&.to_s || env["REMOTE_ADDR"]
      end

      # Extracts the user agent string from the Rack environment.
      #
      # Retrieves the HTTP User-Agent header to provide context about
      # the client application or browser making the request.
      #
      # @param [Hash] env The Rack environment hash
      # @return [String, nil] The user agent string if found, nil otherwise
      # @api private
      #
      def user_agent_from_env(env)
        env["HTTP_USER_AGENT"]
      end
    end
  end
end
