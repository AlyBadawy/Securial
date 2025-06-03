module Securial
  class StatusController < ApplicationController
    def show
      Securial.logger.info("Status check initiated")
    end
  end
end
