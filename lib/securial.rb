require "securial/version"
require "securial/engine"
require "securial/logger"

require "jbuilder"

module Securial
  class << self
    attr_accessor :configuration
    attr_accessor :logger

    def configuration
      @configuration ||= Securial::Config::Configuration.new
    end

    def configuration=(config)
      @configuration = config
      Securial::Config::Validation.validate_all!(configuration)
    end

    def configure
      yield(configuration)
    end

    def logger
      @logger ||= Securial::Logger.build
    end

    # Returns the pluralized form of the admin role.
    # This behavior is intentional and aligns with the project's routing conventions.
    def admin_namespace
      configuration.admin_role.to_s.pluralize.downcase
    end
  end
end
