module Securial
  module Middleware
    class RequestTagLogger
      def initialize(app, logger = Securial.logger)
        @app = app
        @logger = logger
      end

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

      def request_id_from_env(env)
        env["action_dispatch.request_id"] || env["HTTP_X_REQUEST_ID"]
      end

      def ip_from_env(env)
        # This will extract the remote IP address
        env["action_dispatch.remote_ip"]&.to_s || env["REMOTE_ADDR"]
      end

      def user_agent_from_env(env)
        env["HTTP_USER_AGENT"]
      end
    end
  end
end
