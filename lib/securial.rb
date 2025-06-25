# Main entry point for the Securial gem.
#
# This file serves as the primary entry point for the Securial gem,
# requiring necessary dependencies, setting up the module structure,
# and establishing method delegation.
#
# The Securial gem is a mountable Rails engine that provides authentication
# and authorization capabilities for Rails applications, supporting JWT,
# API tokens, and session-based authentication.
#
# @example Basic usage in a Rails application
#   # In Gemfile
#   gem 'securial'
#
#   # In routes.rb
#   Rails.application.routes.draw do
#     mount Securial::Engine => '/securial'
#   end
#
# @see Securial::Engine
# @see Securial::VERSION
#
require "securial/version"
require "securial/engine"

require "jbuilder"

# Main namespace for the Securial authentication and authorization framework.
#
# This module provides access to core functionality of the Securial gem
# by exposing key helper methods and serving as the root namespace for
# all Securial components.
#
module Securial
  extend self

  # @!method protected_namespace
  #   Returns the namespace used for protected resources in the application.
  #   @return [String] the protected namespace designation

  # @!method titleized_admin_role
  #   Returns the admin role name with proper title-case formatting.
  #   @return [String] the admin role title

  delegate :protected_namespace, to: Securial::Helpers::RolesHelper
  delegate :titleized_admin_role, to: Securial::Helpers::RolesHelper
end
