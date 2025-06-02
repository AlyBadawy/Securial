require "rails_helper"

describe "Securial::Engine Initializers" do
  let(:app) { Rails.application }
  let(:engine) { Securial::Engine.instance }
  let(:destination_root) { Securial::Engine.root.join("tmp") }

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
        :reset_password_token
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
end
