# @title Securial Transform Response Keys Middleware
#
# Rack middleware for transforming JSON response keys to client-preferred formats.
#
# This middleware automatically converts outgoing JSON response keys from Ruby's
# snake_case convention to the configured format (camelCase, PascalCase, etc.) to
# match client application expectations. It only processes JSON responses and
# preserves the original response structure and content.
#
# @example Adding middleware to Rails application
#   # config/application.rb
#   config.middleware.use Securial::Middleware::TransformResponseKeys
#
# @example Response transformation with lowerCamelCase
#   # Original Rails response:
#   { "user_name": "john", "email_address": "john@example.com" }
#
#   # Transformed for client:
#   { "userName": "john", "emailAddress": "john@example.com" }
#
# @example Response transformation with UpperCamelCase
#   # Configuration: config.response_keys_format = :UpperCamelCase
#   # Original: { "user_profile": { "first_name": "John" } }
#   # Transformed: { "UserProfile": { "FirstName": "John" } }
#
require "json"

module Securial
  module Middleware
    # Rack middleware that transforms JSON response keys to configured format.
    #
    # This middleware enables Rails applications to output responses in
    # the naming convention expected by client applications (JavaScript,
    # mobile apps, etc.) while maintaining Ruby's snake_case internally.
    #
    class TransformResponseKeys
      # Initializes the middleware with the Rack application and optional format.
      #
      # The format parameter is deprecated in favor of the global configuration
      # setting `Securial.configuration.response_keys_format`.
      #
      # @param [#call] app The Rack application to wrap
      # @param [Symbol] format Deprecated: The key format to use (defaults to :lowerCamelCase)
      #
      # @example
      #   middleware = TransformResponseKeys.new(app)
      #
      # @deprecated Use `Securial.configuration.response_keys_format` instead of format parameter
      #
      def initialize(app, format: :lowerCamelCase)
        @app = app
      end

      # Processes the response and transforms JSON keys if applicable.
      #
      # Intercepts JSON responses, parses the body, transforms all keys to
      # the configured format using the KeyTransformer helper, and replaces
      # the response body with the transformed JSON. Non-JSON responses
      # pass through unchanged.
      #
      # @param [Hash] env The Rack environment hash
      # @return [Array] The Rack response array [status, headers, body] with transformed keys
      #
      # @example JSON transformation
      #   # Original response: { "first_name": "John", "last_name": "Doe" }
      #   # Transformed response: { "firstName": "John", "lastName": "Doe" }
      #
      # @example Non-JSON responses
      #   # HTML, XML, and other content types pass through unchanged
      #
      # @example Empty or malformed JSON handling
      #   # Empty responses and invalid JSON are left unchanged
      #
      def call(env)
        status, headers, response = @app.call(env)

        if json_response?(headers)
          body = extract_body(response)

          if body.present?
            format = Securial.configuration.response_keys_format
            transformed = Securial::Helpers::KeyTransformer.deep_transform_keys(JSON.parse(body)) do |key|
              Securial::Helpers::KeyTransformer.camelize(key, format)
            end

            new_body = [JSON.generate(transformed)]
            headers["Content-Length"] = new_body.first.bytesize.to_s
            return [status, headers, new_body]
          end
        end

        [status, headers, response]
      end

      private

      # Checks if the response contains JSON content.
      #
      # @param [Hash] headers The response headers hash
      # @return [Boolean] true if the response has JSON content type
      # @api private
      #
      def json_response?(headers)
        headers["Content-Type"]&.include?("application/json")
      end

      # Extracts the complete response body from the response object.
      #
      # Iterates through the response body parts and concatenates them
      # into a single string for JSON parsing and transformation.
      #
      # @param [#each] response The response body object (responds to #each)
      # @return [String] The complete response body as a string
      # @api private
      #
      # @example
      #   body = extract_body(response)
      #   # => '{"user_name":"john","email":"john@example.com"}'
      #
      def extract_body(response)
        response_body = ""
        response.each { |part| response_body << part }
        response_body
      end
    end
  end
end
