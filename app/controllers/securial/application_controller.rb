module Securial
  #
  # ApplicationController
  #
  # This is the base controller for the Securial engine, inheriting from ActionController::API.
  # and provides common functionality for all Securial controllers, including:
  #   - Custom view path configuration
  #   - Common exception handling for API responses
  #   - Standardized error rendering
  #
  # All other controllers in the Securial engine inherit from this controller
  # to ensure consistent behavior across the API.
  #
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
    # @param [ActiveRecord::RecordNotFound] exception The exception raised when a record is not found
    # @return [void]
    def render_404
      render status: :not_found, json: {
        errors: ["Record not found"],
        instructions: "Please check the requested resource and try again.",
      }
    end

    # Renders a standardized 400 Bad Request JSON response.
    #
    # Called automatically when an ActionController::ParameterMissing exception is raised,
    # providing the client with information about the missing parameter.
    #
    # @param [ActionController::ParameterMissing] exception The exception raised for missing parameters
    # @return [void]
    def render_400(exception)
      render status: :bad_request, json: {
        errors: [exception.message],
        instructions: "Please ensure all required parameters are provided and formatted correctly.",
       }
    end
  end
end
