# lib/securial/middleware/transform_request_keys.rb
require "json"

module Securial
  module Middleware
    class TransformRequestKeys
      def initialize(app)
        @app = app
      end

      def call(env)
        if env["CONTENT_TYPE"]&.include?("application/json") && Securial.configuration.response_keys_format != :snake_case
          req = Rack::Request.new(env)
          if req.body.size > 0
            raw = req.body.read
            req.body.rewind
            begin
              parsed = JSON.parse(raw)
              transformed = Securial::KeyTransformer.deep_transform_keys(parsed) do |key|
                Securial::KeyTransformer.underscore(key)
              end
              env["rack.input"] = StringIO.new(JSON.dump(transformed))
            rescue JSON::ParserError
              # noop
            end
          end
        end
        @app.call(env)
      end
    end
  end
end
