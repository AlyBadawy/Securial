module Securial
  class Engine < ::Rails::Engine
    initializer "securial.filter_parameters" do |app|
      app.config.filter_parameters += [
        :password,
        :password_confirmation,
        :password_reset_token,
        :reset_password_token,
      ]
    end

    initializer "securial.factory_bot", after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot)
        FactoryBot.definition_file_paths << Engine.root.join("lib", "securial", "factories")
        require_relative "../generators/factory_bot/model/model_generator"
      end
    end

    initializer "securial.security.request_rate_limiter" do |app|
      if Securial.configuration.rate_limiting_enabled
        Securial::Security::RequestRateLimiter.apply!
        app.middleware.use Rack::Attack
      end
    end

    initializer "securial.middleware.transform_request_keys" do |app|
      app.middleware.use Securial::Middleware::TransformRequestKeys
    end

    initializer "securial.middleware.transform_response_keys" do |app|
      app.middleware.use Securial::Middleware::TransformResponseKeys
    end

    initializer "securial.middleware.logger" do |app|
      app.middleware.use Securial::Middleware::RequestTagLogger
    end

    initializer "securial.middleware.response_headers" do |app|
      app.middleware.use Securial::Middleware::ResponseHeaders
    end

    initializer "securial.extend_application_controller" do
      ActiveSupport.on_load(:action_controller_base) { include Securial::Identity }
      ActiveSupport.on_load(:action_controller_api)  { include Securial::Identity }
    end

    initializer "securial.action_mailer.preview_path", after: "action_mailer.set_configs" do |app|
      app.config.action_mailer.preview_paths ||= []
      app.config.action_mailer.preview_paths |= [root.join("spec/mailers/previews").to_s]
    end
  end
end
