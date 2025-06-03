module Securial
  module Helpers
    module NormalizingHelper
      module_function

      def normalize_email_address(email)
        return "" if email.empty?

        email.strip.downcase
      end

      def normalize_role_name(role_name)
        return "" if role_name.empty?

        role_name.strip.downcase.titleize
      end
    end
  end
end
