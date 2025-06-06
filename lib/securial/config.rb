require "securial/config/configuration"
require "securial/config/signature"
require "securial/config/validation"


module Securial
  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Config::Configuration.new
    end

    def configuration=(config)
      if config.is_a?(Config::Configuration)
        @configuration = config
        Securial::Config::Validation.validate_all!(configuration)
      else
        raise ArgumentError, "Expected an instance of Securial::Config::Configuration"
      end
    end

    def configure
      yield(configuration) if block_given?
      Securial::Config::Validation.validate_all!(configuration)
    end
  end
end
