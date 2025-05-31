# lib/securial/middleware/transform_response_keys.rb
require "json"

module Securial
  module Middleware
    class TransformResponseKeys
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, response = @app.call(env)

        if json_response?(headers)
          body = extract_body(response)

          if body.present?
            format = Securial.configuration.response_keys_format
            transformed = KeyTransformer.deep_transform_keys(JSON.parse(body)) do |key|
              KeyTransformer.camelize(key, format)
            end

            new_body = [JSON.generate(transformed)]
            headers["Content-Length"] = new_body.first.bytesize.to_s
            return [status, headers, new_body]
          end
        end

        [status, headers, response]
      end

      private

      def json_response?(headers)
        headers["Content-Type"]&.include?("application/json")
      end

      def extract_body(response)
        response_body = ""
        response.each { |part| response_body << part }
        response_body
      end
    end
  end
end
