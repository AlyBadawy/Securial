module Securial
  module Middleware
    # This middleware removes sensitive headers from the request environment.
    # It is designed to enhance security by ensuring that sensitive information
    # is not inadvertently logged or processed.
    class ResponseHeaders
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, response = @app.call(env)
        headers["X-Securial-Mounted"] = "true"
        headers["X-Securial-Developer"] = "Aly Badawy - https://alybadawy.com | @alybadawy"
        [status, headers, response]
      end
    end
  end
end
