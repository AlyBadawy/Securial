module Securial
  module Helpers
    module RolesHelper
      # This module provides helper methods related to roles.
      # It can be extended with additional role-related functionality as needed.
      class << self
        def protected_namespace
          Securial.configuration.admin_role.to_s.strip.underscore.pluralize
        end

        def titleized_admin_role
          Securial.configuration.admin_role.to_s.strip.titleize
        end
      end
    end
  end
end
