module Securial
  module Middleware
    class RequestLoggerTag
      def initialize(app)
        @app = app
      end

      def call(env)
        request_id = env["action_dispatch.request_id"] || env["HTTP_X_REQUEST_ID"]
        tags = ["Securial"]
        tags << request_id if request_id

        logger = Securial.logger || Rails.logger || ::Logger.new(IO::NULL)
        tagged_logger = logger.is_a?(ActiveSupport::TaggedLogging) ? logger : ActiveSupport::TaggedLogging.new(logger)
        tagged_logger.tagged(*tags) { @app.call(env) }
      end
    end
  end
end
