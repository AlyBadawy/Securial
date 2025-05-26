require_relative "./logger"

require_relative "./errors/config_errors"
require_relative "./errors/session_errors"

require_relative "./configuration"

require_relative "./helpers/auth_helper"
require_relative "./helpers/normalizing_helper"
require_relative "./helpers/regex_helper"

require_relative "./route_inspector"

require_relative "./middleware/request_logger_tag"
require "jwt"

module Securial
  class Engine < ::Rails::Engine
    isolate_namespace Securial

    initializer "securial.filter_parameters" do |app|
      app.config.filter_parameters += [
        :password,
        :password_confirmation,
        :password_reset_token,
        :reset_password_token
      ]
    end

    initializer "securial.logger" do
      Securial.const_set(:ENGINE_LOGGER, Securial::Logger.build)
    end

    initializer "securial.engine_initialized" do |app|
      Securial::ENGINE_LOGGER.info("[Securial] Engine mounted. Host app: #{app.class.name}")
    end

    initializer "securial.factories", after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot)
        FactoryBot.definition_file_paths << Engine.root.join("lib", "securial", "factories")
      end
    end

    initializer "securial.load_factory_bot_generator" do
      require_relative "../generators/factory_bot/model/model_generator"
    end

    initializer "securial.extend_application_controller" do
      ActiveSupport.on_load(:action_controller_base) do
        include Securial::Identity
      end

      ActiveSupport.on_load(:action_controller_api) do
        include Securial::Identity
      end
    end

    config.generators.api_only = true

    config.autoload_paths += Dir["#{config.root}/lib/generators"]

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

      # Add JBuilder configuration
      g.template_engine :jbuilder
    end

    initializer "securial.middleware" do |app|
      app.middleware.use Securial::Middleware::RequestLoggerTag
    end

    initializer "securial.log_engine_loaded", after: :load_config_initializers do
      Rails.application.config.after_initialize do
        Securial::ENGINE_LOGGER.info("[Securial] Engine fully initialized in #{Rails.env} environment.")
      end
    end
  end
end
