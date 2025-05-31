require 'rails_helper'

RSpec.describe Securial::Engine do
  describe 'controller extensions' do
    describe 'ActionController::Base integration' do
      let(:controller) { ActionController::Base.new }

      it 'includes Securial::Identity in ActionController::Base' do
        expect(ActionController::Base.included_modules).to include(Securial::Identity)
      end

      it 'makes Identity methods available to Base controllers' do
        expect(controller).to respond_to(:current_user)
        expect(controller).to respond_to(:authenticate_admin!)
      end
    end

    describe 'ActionController::API integration' do
      let(:controller) { ActionController::API.new }

      it 'includes Securial::Identity in ActionController::API' do
        expect(ActionController::API.included_modules).to include(Securial::Identity)
      end

      it 'makes Identity methods available to API controllers' do
        expect(controller).to respond_to(:current_user)
        expect(controller).to respond_to(:authenticate_admin!)
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
        initializer = described_class.initializers.find { |i| i.name == "securial.filter_parameters" }
        expect(initializer).to be_present

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

    describe 'helper methods' do
      let(:base_controller) { ActionController::Base.new }

      it 'registers current_user as a helper method in Base controllers' do
        expect(ActionController::Base._helper_methods).to include(:current_user)
      end

      it 'does not register helper methods in API controllers' do
        expect(ActionController::API._helper_methods).to be_empty
      end
    end
  end
end
