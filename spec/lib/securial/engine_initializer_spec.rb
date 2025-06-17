require "rails_helper"

describe "Securial::Engine Initializers" do
  let(:app) { Rails.application }
  let(:engine) { Securial::Engine.instance }
  let(:destination_root) { Securial::Engine.root.join("tmp") }

  describe "filter_parameters initializer" do
    let(:app) { instance_double(Rails::Application, config: config) }
    let(:initial_filter_parameters) { [:existing_param] }
    let(:config) do
      instance_double(Rails::Application::Configuration).tap do |c|
        allow(c).to receive(:filter_parameters).and_return(initial_filter_parameters)
        allow(c).to receive(:filter_parameters=) do |new_params|
          # This simulates the += operation's behavior
          initial_filter_parameters.replace(new_params)
        end
      end
    end

    it "adds sensitive parameters to filter_parameters" do
      # Find the initializer we want to test
      initializer = engine.initializers.find { |i| i.name == "securial.filter_parameters" }
      expect(initializer).to be_an_instance_of(Rails::Initializable::Initializer)

      # Run the initializer
      initializer.run(app)

      # Verify that our sensitive parameters were added
      sensitive_params = [
        :password,
        :password_confirmation,
        :password_reset_token,
        :reset_password_token,
      ]

      sensitive_params.each do |param|
        expect(initial_filter_parameters).to include(param)
      end

      # Ensure the existing parameters are preserved
      expect(initial_filter_parameters).to include(:existing_param)

      # Verify total count (1 existing + 4 new parameters)
      expect(initial_filter_parameters.length).to eq(5)
    end
  end

  describe "securial.factory_bot" do
    context "when FactoryBot is defined" do
      before do
        stub_const("FactoryBot", Module.new do
          def self.definition_file_paths
            @paths ||= []
          end

          def self.definition_file_paths=(paths)
            @paths = paths
          end
        end)
        allow(engine).to receive(:root).and_return(Pathname.new("/dummy/path"))
      end

      it "adds engine factories path to FactoryBot definition paths" do
        FactoryBot.definition_file_paths = []

        engine.initializers.find { |i| i.name == "securial.factory_bot" }.run(app)

        expected_path = engine.root.join("lib", "securial", "factories")
        expect(FactoryBot.definition_file_paths).to include(expected_path)
      end
    end

    context "when FactoryBot is not defined" do
      before do
        hide_const("FactoryBot") if defined?(FactoryBot)
      end

      it "does not raise error" do
        expect {
          engine.initializers.find { |i| i.name == "securial.factory_bot" }.run(app)
        }.not_to raise_error
      end
    end
  end

  describe "securial.security.request_rate_limiter" do
    let(:middleware_stack) { instance_double(ActionDispatch::MiddlewareStack) }

    before do
      allow(app).to receive(:middleware).and_return(middleware_stack)
      allow(middleware_stack).to receive(:use)
    end

    context "when rate limiting is enabled" do
      before do
        allow(Securial.configuration).to receive(:rate_limiting_enabled).and_return(true)
        allow(Securial::Security::RequestRateLimiter).to receive(:apply!)
      end

      it "applies the request rate limiter and uses Rack::Attack" do
        engine.initializers.find { |i| i.name == "securial.security.request_rate_limiter" }.run(app)
        expect(Securial::Security::RequestRateLimiter).to have_received(:apply!)
        expect(middleware_stack).to have_received(:use).with(Rack::Attack)
      end
    end

    context "when rate limiting is disabled" do
      before do
        allow(Securial.configuration).to receive(:rate_limiting_enabled).and_return(false)
        allow(Securial::Security::RequestRateLimiter).to receive(:apply!)
      end

      it "does not apply the request rate limiter or use Rack::Attack" do
        engine.initializers.find { |i| i.name == "securial.security.request_rate_limiter" }.run(app)
        expect(Securial::Security::RequestRateLimiter).not_to have_received(:apply!)
        expect(middleware_stack).not_to have_received(:use).with(Rack::Attack)
      end
    end
  end

  describe "securial.middleware.transform_request_keys" do
    it "adds TransformRequestKeys middleware" do
      fake_middleware = instance_double(ActionDispatch::MiddlewareStack, use: true)
      app = instance_double("RailsApp", middleware: fake_middleware) # rubocop:disable RSpec/VerifiedDoubleReference
      engine = Securial::Engine.instance

      engine.initializers.find { |i| i.name == "securial.middleware.transform_request_keys" }.run(app)

      expect(fake_middleware).to have_received(:use).with(Securial::Middleware::TransformRequestKeys)
    end
  end

  describe "securial.middleware.transform_response_keys" do
    it "adds TransformResponseKeys middleware" do
      fake_middleware = instance_double(ActionDispatch::MiddlewareStack, use: true)
      app = instance_double("RailsApp", middleware: fake_middleware) # rubocop:disable RSpec/VerifiedDoubleReference
      engine = Securial::Engine.instance
      engine.initializers.find { |i| i.name == "securial.middleware.transform_response_keys" }.run(app)
      expect(fake_middleware).to have_received(:use).with(Securial::Middleware::TransformResponseKeys)
    end
  end

  describe "securial.middleware.logger" do
    it "adds RequestTagLogger middleware" do
      fake_middleware = instance_double(ActionDispatch::MiddlewareStack, use: true)
      app = instance_double("RailsApp", middleware: fake_middleware) # rubocop:disable RSpec/VerifiedDoubleReference
      engine = Securial::Engine.instance

      engine.initializers.find { |i| i.name == "securial.middleware.logger" }.run(app)

      expect(fake_middleware).to have_received(:use).with(Securial::Middleware::RequestTagLogger)
    end
  end

  describe "securial.middleware.response_headers" do
    it "adds ResponseHeaders middleware" do
      fake_middleware = instance_double(ActionDispatch::MiddlewareStack, use: true)
      app = instance_double("RailsApp", middleware: fake_middleware) # rubocop:disable RSpec/VerifiedDoubleReference
      engine = Securial::Engine.instance

      engine.initializers.find { |i| i.name == "securial.middleware.response_headers" }.run(app)

      expect(fake_middleware).to have_received(:use).with(Securial::Middleware::ResponseHeaders)
    end
  end

  # rubocop:disable RSpec/VerifiedDoubles
  describe "securial.action_mailer.preview_path" do
    it "sets the preview path for ActionMailer" do
      # Create a mock for action_mailer with preview_paths
      action_mailer_config = double("action_mailer_config")
      preview_paths = []
      allow(action_mailer_config).to receive(:preview_paths).and_return(preview_paths)
      allow(action_mailer_config).to receive(:preview_paths=) { |paths| preview_paths.replace(paths) }

      # Create a mock app config - use double instead of instance_double
      app_config = double("app_config")
      allow(app_config).to receive(:action_mailer).and_return(action_mailer_config)

      # Set up the app to use our mock config
      allow(app).to receive(:config).and_return(app_config)

      # Run the initializer
      engine.initializers.find { |i| i.name == "securial.action_mailer.preview_path" }.run(app)

      # Check that the preview path was added
      expected_path = engine.root.join("spec", "mailers", "previews").to_s
      expect(preview_paths).to include(expected_path)
    end

    it "appends to existing preview_paths" do
      action_mailer_config = double("action_mailer_config")
      preview_paths = ["/existing/path"]
      allow(action_mailer_config).to receive(:preview_paths).and_return(preview_paths)
      allow(action_mailer_config).to receive(:preview_paths=) { |paths| preview_paths.replace(paths) }

      app_config = double("app_config")
      allow(app_config).to receive(:action_mailer).and_return(action_mailer_config)

      allow(app).to receive(:config).and_return(app_config)

      engine.initializers.find { |i| i.name == "securial.action_mailer.preview_path" }.run(app)

      expected_path = engine.root.join("spec", "mailers", "previews").to_s
      expect(preview_paths).to include("/existing/path")
      expect(preview_paths).to include(expected_path)
    end
  end
  # rubocop:enable RSpec/VerifiedDoubles
end
