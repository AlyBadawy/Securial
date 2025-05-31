require "jwt"

require "securial/logger"
require "securial/key_transformer"
require "securial/config"
require "securial/helpers"
require "securial/auth"
require "securial/inspectors"
require "securial/middlewares"
require "securial/version_checker"
module Securial
  class Engine < ::Rails::Engine
    isolate_namespace Securial

    # Set API-only mode and autoload custom generator paths
    config.api_only = true
    config.generators.api_only = true
    config.autoload_paths += Dir["#{config.root}/lib/generators"]

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

    initializer "securial.log_initialization" do |app|
      log "[Initializing Engine] Host app: #{app.class.name}"
    end

    initializer "securial.validate_config" do
      log "[Validating configuration] from `config/initializers/securial.rb`..."
      Securial::Config::Validation.validate_all!(Securial.configuration)
    end

    initializer "securial.extend_application_controller" do
      ActiveSupport.on_load(:action_controller_base) { include Securial::Identity }
      ActiveSupport.on_load(:action_controller_api)  { include Securial::Identity }
    end

    initializer "securial.factory_bot", after: "factory_bot.set_factory_paths" do
      FactoryBot.definition_file_paths << Engine.root.join("lib", "securial", "factories") if defined?(FactoryBot)
    end

    initializer "securial.factory_bot_generator" do
      require_relative "./generators/factory_bot/model/model_generator"
    end

    initializer "securial.middleware" do |app|
      middleware.use Securial::Middleware::RequestLoggerTag
      middleware.use Securial::Middleware::TransformRequestKeys
      middleware.use Securial::Middleware::TransformResponseKeys
      if Securial.configuration.rate_limiting_enabled
        require "rack/attack"
        require_relative "./rack_attack"
        middleware.use Rack::Attack
      end
    end

    initializer "securial.version_check" do
      config.after_initialize do
        Securial::VersionChecker.check_latest_version
      end
    end

    initializer "securial.log_ready", after: :load_config_initializers do
      Rails.application.config.after_initialize do
        log "[Engine fully initialized] Environment: #{Rails.env}"
      end
    end

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

    private

    def log(message)
      Securial.logger.info("[Securial] #{message}")
    end
  end
end
