# @title Securial Transform Request Keys Middleware
#
# Rack middleware for transforming JSON request body keys to Ruby conventions.
#
# This middleware automatically converts incoming JSON request body keys from
# camelCase or PascalCase to snake_case, allowing Rails applications to receive
# JavaScript-style APIs while maintaining Ruby naming conventions internally.
# It only processes JSON requests and gracefully handles malformed JSON.
#
# @example Adding middleware to Rails application
#   # config/application.rb
#   config.middleware.use Securial::Middleware::TransformRequestKeys
#
# @example Request transformation
#   # Incoming JSON request body:
#   { "userName": "john", "emailAddress": "john@example.com" }
#
#   # Transformed for Rails application:
#   { "user_name": "john", "email_address": "john@example.com" }
#
require "json"
require "stringio"

module Securial
  module Middleware
    # Rack middleware that transforms JSON request body keys to snake_case.
    #
    # This middleware enables Rails applications to accept camelCase JSON
    # from frontend applications while automatically converting keys to
    # Ruby's snake_case convention before they reach the application.
    #
    class TransformRequestKeys
      # Initializes the middleware with the Rack application.
      #
      # @param [#call] app The Rack application to wrap
      #
      # @example
      #   middleware = TransformRequestKeys.new(app)
      #
      def initialize(app)
        @app = app
      end

      # Processes the request and transforms JSON body keys if applicable.
      #
      # Intercepts JSON requests, parses the body, transforms all keys to
      # snake_case using the KeyTransformer helper, and replaces the request
      # body with the transformed JSON. Non-JSON requests pass through unchanged.
      #
      # @param [Hash] env The Rack environment hash
      # @return [Array] The Rack response array [status, headers, body]
      #
      # @example JSON transformation
      #   # Original request body: { "firstName": "John", "lastName": "Doe" }
      #   # Transformed body: { "first_name": "John", "last_name": "Doe" }
      #
      # @example Non-JSON requests
      #   # Form data, XML, and other content types pass through unchanged
      #
      # @example Malformed JSON handling
      #   # Invalid JSON is left unchanged and passed to the application
      #   # The application can handle the JSON parsing error appropriately
      #
      def call(env)
        if json_request?(env)
          transform_json_body(env)
        end

        @app.call(env)
      end

      private

      # Checks if the request contains JSON content.
      #
      # @param [Hash] env The Rack environment hash
      # @return [Boolean] true if the request has JSON content type
      # @api private
      #
      def json_request?(env)
        env["CONTENT_TYPE"]&.include?("application/json")
      end

      # Transforms JSON request body keys to snake_case.
      #
      # Reads the request body, parses it as JSON, transforms all keys
      # to snake_case, and replaces the original body with the transformed
      # JSON. Gracefully handles empty bodies and malformed JSON.
      #
      # @param [Hash] env The Rack environment hash
      # @return [void]
      # @api private
      #
      def transform_json_body(env)
        req = Rack::Request.new(env)

        return unless request_has_body?(req)

        raw_body = read_request_body(req)

        begin
          parsed_json = JSON.parse(raw_body)
          transformed_json = transform_keys_to_snake_case(parsed_json)
          replace_request_body(env, transformed_json)
        rescue JSON::ParserError
          # Malformed JSON - leave unchanged for application to handle
        end
      end

      # Checks if the request has a body to process.
      #
      # @param [Rack::Request] req The Rack request object
      # @return [Boolean] true if the request has a non-empty body
      # @api private
      #
      def request_has_body?(req)
        (req.body&.size || 0) > 0
      end

      # Reads and rewinds the request body.
      #
      # @param [Rack::Request] req The Rack request object
      # @return [String] The raw request body content
      # @api private
      #
      def read_request_body(req)
        raw = req.body.read
        req.body.rewind
        raw
      end

      # Transforms all keys in the JSON structure to snake_case.
      #
      # @param [Object] json_data The parsed JSON data structure
      # @return [Object] The data structure with transformed keys
      # @api private
      #
      def transform_keys_to_snake_case(json_data)
        Securial::Helpers::KeyTransformer.deep_transform_keys(json_data) do |key|
          Securial::Helpers::KeyTransformer.underscore(key)
        end
      end

      # Replaces the request body with transformed JSON.
      #
      # @param [Hash] env The Rack environment hash
      # @param [Object] transformed_data The transformed JSON data
      # @return [void]
      # @api private
      #
      def replace_request_body(env, transformed_data)
        new_body = JSON.dump(transformed_data)
        env["rack.input"] = StringIO.new(new_body)
        env["rack.input"].rewind
      end
    end
  end
end
