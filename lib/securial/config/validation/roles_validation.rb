require "securial/error"

module Securial
  module Config
    module Validation
      module RolesValidation
        class << self
          def validate!(securial_config)
            if securial_config.admin_role.nil? || securial_config.admin_role.to_s.strip.empty?
              error_message = "Admin role is not set."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::RolesValidationError, error_message
            end

            unless securial_config.admin_role.is_a?(Symbol) || securial_config.admin_role.is_a?(String)
              error_message = "Admin role must be a Symbol or String."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::RolesValidationError, error_message
            end

            admin_role_downcase = securial_config.admin_role.to_s.downcase
            if admin_role_downcase == "account" || admin_role_downcase == "accounts"
              error_message = "The admin role cannot be 'account' or 'accounts' as it conflicts with the default routes."
              Securial.logger.fatal(error_message)
              raise Securial::Error::Config::RolesValidationError, error_message
            end
          end
        end
      end
    end
  end
end
