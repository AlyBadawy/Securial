require_relative "logger/builder"

module Securial
  class << self
    def logger
      @logger ||= Logger::Builder.build
    end

    def logger=(logger)
      @logger = logger
    end
  end
end
