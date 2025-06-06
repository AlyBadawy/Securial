require 'rails_helper'

  RSpec.describe Securial::PasswordsController, type: :routing do
    routes { Securial::Engine.routes }

    describe 'routing' do
      it 'routes to #forgot_password' do
        expect(post: "/password/forgot").to route_to("securial/passwords#forgot_password", format: :json)
      end

      it 'routes to #reset_password' do
        expect(put: "/password/reset").to route_to("securial/passwords#reset_password", format: :json)
      end
    end
  end
