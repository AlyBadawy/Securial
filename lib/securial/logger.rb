require_relative "logger/builder"

module Securial
  extend self
  attr_accessor :logger

  def logger
    @logger ||= Logger::Builder.build
  end

  def logger=(logger)
    @logger = logger
  end
end
