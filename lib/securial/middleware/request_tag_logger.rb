module Securial
  module Middleware
    class RequestTagLogger
      def initialize(app, logger = Securial.logger)
        @app = app
        @logger = logger
      end

      def call(env)
        request_id = request_id_from_env(env)
        tags = ["Securial"]
        tags << request_id if request_id

        @logger.tagged(*tags) do
          @app.call(env)
        end
      end

      private

      def request_id_from_env(env)
        # Rails sets ActionDispatch::RequestId in the env by default
        env["action_dispatch.request_id"] || env["HTTP_X_REQUEST_ID"]
      end
    end
  end
end
