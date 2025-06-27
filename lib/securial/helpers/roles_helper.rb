# @title Securial Roles Helper
#
# Role and permission utilities for the Securial framework.
#
# This module provides helper methods for working with user roles and permissions
# throughout the application. It handles role name formatting, namespace generation,
# and other role-related operations to ensure consistency across the system.
#
# @example Getting the admin namespace for routing
#   RolesHelper.protected_namespace
#   # => "admins" (if admin_role is :admin)
#
# @example Getting a formatted admin role name for display
#   RolesHelper.titleized_admin_role
#   # => "Super Admin" (if admin_role is :super_admin)
#
module Securial
  module Helpers
    # Helper methods for role management and formatting.
    #
    # This module provides utility methods for working with user roles,
    # including namespace generation for protected routes and role name
    # formatting for user interfaces. It centralizes role-related logic
    # to ensure consistent behavior across the application.
    #
    module RolesHelper
      extend self

      # Generates a namespace string for protected admin routes.
      #
      # Converts the configured admin role into a pluralized, underscored
      # namespace suitable for use in Rails routing and controller organization.
      # This ensures admin routes are consistently organized under the
      # appropriate namespace.
      #
      # @return [String] The pluralized, underscored admin role namespace
      #
      # @example With default admin role
      #   # When Securial.configuration.admin_role = :admin
      #   protected_namespace
      #   # => "admins"
      #
      # @example With custom admin role
      #   # When Securial.configuration.admin_role = :super_admin
      #   protected_namespace
      #   # => "super_admins"
      #
      # @example With spaced role name
      #   # When Securial.configuration.admin_role = "Site Administrator"
      #   protected_namespace
      #   # => "site_administrators"
      #
      def protected_namespace
        Securial.configuration.admin_role.to_s.strip.underscore.pluralize
      end

      # Formats the admin role name for user interface display.
      #
      # Converts the configured admin role into a human-readable, title-cased
      # string suitable for display in user interfaces, form labels, and
      # user-facing messages.
      #
      # @return [String] The title-cased admin role name
      #
      # @example With default admin role
      #   # When Securial.configuration.admin_role = :admin
      #   titleized_admin_role
      #   # => "Admin"
      #
      # @example With underscored role name
      #   # When Securial.configuration.admin_role = :super_admin
      #   titleized_admin_role
      #   # => "Super Admin"
      #
      # @example With already formatted role
      #   # When Securial.configuration.admin_role = "Site Administrator"
      #   titleized_admin_role
      #   # => "Site Administrator"
      #
      def titleized_admin_role
        Securial.configuration.admin_role.to_s.strip.titleize
      end
    end
  end
end
