# @title Securial Rails Engine
#
# Rails engine configuration for the Securial framework.
#
# This file defines the core Rails engine that powers Securial, setting up
# namespace isolation, generator defaults, and loading all required components.
# The engine configuration establishes how Securial integrates with host Rails
# applications and defines the conventions used throughout the codebase.
#
# @example Mounting the engine in a Rails application
#   # In config/routes.rb
#   Rails.application.routes.draw do
#     mount Securial::Engine => '/securial'
#   end
#
# @example Accessing engine routes in views or controllers
#   # Generate path to Securial login
#   securial.login_path
#
#   # Generate URL to Securial user profile
#   securial.user_url(@user)
#
require "securial/auth"
require "securial/config"
require "securial/error"
require "securial/helpers"
require "securial/logger"
require "securial/middleware"
require "securial/security"

module Securial
  # Rails engine implementation for the Securial framework.
  #
  # This class defines the core engine that powers Securial's integration with
  # Rails applications. It isolates all Securial components within their own
  # namespace to prevent conflicts with host application code and configures
  # generator defaults to ensure consistent code generation.
  #
  # The engine handles:
  # - Namespace isolation to prevent conflicts
  # - Configuration of generators for consistent code generation
  # - Setting up Securial's API-only mode for JSON responses
  # - Loading initializers for various framework components
  #
  # @see https://guides.rubyonrails.org/engines.html Rails Engines Guide
  #
  class Engine < ::Rails::Engine
    # Isolates the Securial namespace to prevent conflicts with host applications
    isolate_namespace Securial

    # Configures the engine for API-only mode by default
    config.generators.api_only = true

    # Sets up standard generator configurations for consistent code generation
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
      g.fixture_replacement :factory_bot
      g.template_engine :jbuilder
    end
  end
end

# Load engine initializers that configure various aspects of the framework
require_relative "engine_initializers"
