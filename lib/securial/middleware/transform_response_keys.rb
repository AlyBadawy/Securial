module Securial
  module Middleware
    # This middleware transforms response keys to a specified format.
    # It uses the KeyTransformer helper to apply the transformation.
    #
    # It reads the response body if the content type is JSON and transforms
    # the keys to the specified format (default is lowerCamelCase).
    class TransformResponseKeys
      def initialize(app, format: :lowerCamelCase)
        @app = app
      end

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
