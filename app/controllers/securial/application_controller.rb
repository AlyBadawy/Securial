module Securial
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

    def render_404
      render status: :not_found, json: { error: "Record not found" }
    end

    def render_400(exception)
      render status: :bad_request, json: { error: exception.message }
    end
  end
end
