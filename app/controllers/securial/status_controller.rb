module Securial
  class StatusController < ApplicationController
    skip_authentication!

    def show
      Securial.logger.info("Status check initiated")
    end
  end
end
