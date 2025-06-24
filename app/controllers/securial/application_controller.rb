module Securial
  # Base controller for all Securial API endpoints.
  #
  # This controller inherits from ActionController::API and provides common
  # functionality for all Securial controllers, including:
  #   - Custom view path configuration
  #   - Common exception handling for API responses
  #   - Standardized error rendering
  #
  # All other controllers in the Securial engine should inherit from this controller
  # to ensure consistent behavior across the API.
  class ApplicationController < ActionController::API
    prepend_view_path Securial::Engine.root.join("app", "views")

    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::ParameterMissing, with: :render_400

    private

    # Renders a standardized 404 Not Found JSON response.
    #
    # Called automatically when an ActiveRecord::RecordNotFound exception is raised,
    # ensuring consistent error responses across the API.
    #
    # @return [void]
    def render_404
      render status: :not_found, json: { error: "Record not found" }
    end

    # Renders a standardized 400 Bad Request JSON response.
    #
    # Called automatically when an ActionController::ParameterMissing exception is raised,
    # providing the client with information about the missing parameter.
    #
    # @param [ActionController::ParameterMissing] exception The exception that was raised
    # @return [void]
    def render_400(exception)
      render status: :bad_request, json: { error: exception.message }
    end
  end
end
