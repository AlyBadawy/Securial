require "securial/auth"
require "securial/config"
require "securial/error"
require "securial/helpers"
require "securial/logger"
require "securial/middleware"
require "securial/security"

module Securial
  class Engine < ::Rails::Engine
    isolate_namespace Securial

    config.generators.api_only = true

    config.generators do |g|
      g.orm :active_record, primary_key_type: :string
      g.test_framework :rspec,
                       fixtures: false,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: true,
                       controller_specs: true,
                       request_specs: true,
                       model_specs: true
      g.fixture_replacement :factory_bot, dir: "lib/securial/factories"
      g.template_engine :jbuilder
    end
  end
end

require_relative "engine_initializers"
