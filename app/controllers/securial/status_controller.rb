module Securial
  #
  # StatusController
  #
  # Controller for checking system status and authentication state.
  #
  # This controller provides a simple endpoint for checking if the Securial
  # system is operational and retrieving basic information about the current
  # authentication state, if applicable. This endpoint is publicly accessible
  # and does not require authentication.
  #
  # Typically used for:
  #   - Health checks from monitoring systems
  #   - Client applications to verify API availability
  #   - Testing authentication status without making authenticated requests
  #
  # Routes typically mounted at Securial/status/* in the host application.
  #
  class StatusController < ApplicationController
    skip_authentication!

    # Shows the current Securial Engine status.
    #
    # Provides information about the engine's operational state and,
    # if the request includes a valid authentication token, the current user.
    # This endpoint is always accessible without authentication.
    #
    # @return [void] Renders status information with 200 OK status
    def show
      @current_user = current_user
      Securial.logger.info("Status check initiated")
      render :show, status: :ok
    end
  end
end
