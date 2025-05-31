
require 'rails_helper'

module Securial
  RSpec.describe Inspectors::RouteInspector do
    before do
      class TestController < ApplicationController # rubocop:disable RSpec/LeakyConstantDeclaration
        def not_found; raise ActiveRecord::RecordNotFound; end
        def bad_request; raise ActionController::ParameterMissing, "param"; end
        def invalid_encoding; raise JWT::DecodeError; end
        def expired_signature; raise JWT::ExpiredSignature; end
      end

      Rails.application.routes.draw do
        mount Securial::Engine => "/securial"
      end

      Securial::Engine.routes.draw do
        get "/test/not_found", to: "test#not_found"
        get "/test/bad_request", to: "test#bad_request"
        get "/test/invalid_encoding", to: "test#invalid_encoding"
        get "/test/expired_signature", to: "test#expired_signature"
      end

      fake_logger = double("Logger").as_null_object # rubocop:disable RSpec/VerifiedDoubles
      allow(Securial).to receive(:logger).and_return(fake_logger)
    end

    after do
      Securial.send(:remove_const, :TestController) # rubocop:disable RSpec/RemoveConst
      Securial::Engine.routes.clear!
      Rails.application.reload_routes!
    end

    describe ".print_routes" do
      it "prints headers and route details" do
        described_class.print_routes

        expect(Securial.logger).to have_received(:debug).with("Securial engine routes:")
        expect(Securial.logger).to have_received(:debug).with(/-{120}/).twice
        expect(Securial.logger).to have_received(:debug).with(/Verb.*Path.*Controller#Action/)

        route_details = /test#not_found|test#bad_request|test#invalid_encoding|test#expired_signature/
        expect(Securial.logger).to have_received(:debug).with(route_details)
      end

      it "prints only matching controller routes when filtered" do
        described_class.print_routes(controller: "test")

        expect(Securial.logger).to have_received(:debug).with("Filtered by controller: test")
        route_details = /test#not_found|test#bad_request|test#invalid_encoding|test#expired_signature/
        expect(Securial.logger).to have_received(:debug).with(route_details)
      end

      it "prints appropriate message when no controller matches" do
        described_class.print_routes(controller: "fake")
        expect(Securial.logger).to have_received(:debug).with("Filtered by controller: fake")
        expect(Securial.logger).to have_received(:debug).with("No routes found for controller: fake")
      end

      it "prints appropriate message when no routes exist" do
        Securial::Engine.routes.clear!

        described_class.print_routes

        expect(Securial.logger).to have_received(:debug).with("No routes found for Securial engine")
      end
    end
  end
end
