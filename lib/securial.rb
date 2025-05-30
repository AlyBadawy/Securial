require "securial/version"
require "securial/engine"

require "jbuilder"

module Securial
  class << self
    attr_accessor :configuration

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

    # Returns the pluralized form of the admin role.
    # This behavior is intentional and aligns with the project's routing conventions.
    def admin_namespace
      configuration.admin_role.to_s.pluralize.downcase
    end
  end
end
