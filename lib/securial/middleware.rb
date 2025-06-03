require "securial/middleware/request_tag_logger"

module Securial
  module Middleware
    # This module serves as a namespace for all middleware components in the Securial gem.
    # It currently includes the RequestTagLogger middleware, which tags logs with request IDs.
    #
    # Additional middleware can be added here as the gem evolves.
    #
    # Example usage:
    #   use Securial::Middleware::RequestTagLogger
  end
end
