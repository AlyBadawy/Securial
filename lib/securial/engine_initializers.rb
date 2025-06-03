module Securial
  class Engine < ::Rails::Engine
    initializer "securial.filter_parameters" do |app|
      app.config.filter_parameters += [
        :password,
        :password_confirmation,
        :password_reset_token,
        :reset_password_token
      ]
    end

    initializer "securial.factory_bot", after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot)
        FactoryBot.definition_file_paths << Engine.root.join("lib", "securial", "factories")
        require_relative "../generators/factory_bot/model/model_generator"
      end
    end

    initializer "securial.logger_middleware" do |app|
      app.middleware.use Securial::Middleware::RequestTagLogger
    end
  end
end
