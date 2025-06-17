module Securial
  class StatusController < ApplicationController
    skip_authentication!

    def show
      @current_user = current_user
      Securial.logger.info("Status check initiated")
      render :show, status: :ok, location: nil
    end
  end
end
