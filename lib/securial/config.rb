require "securial/config/configuration"

module Securial
  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Config::Configuration.new
    end

    def configuration=(config)
      if config.is_a?(Config::Configuration)
        @configuration = config
      else
        raise ArgumentError, "Expected an instance of Config::Configuration"
      end
    end

    def configure
      yield(configuration) if block_given?
    end
  end
end
