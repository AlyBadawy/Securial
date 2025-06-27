# @title Securial Normalizing Helpers
#
# Data normalization utilities for the Securial framework.
#
# This module provides utilities for normalizing user input data to ensure
# consistency across the application. It handles common normalization tasks
# like email address formatting and role name standardization to prevent
# data inconsistencies and improve user experience.
#
# @example Normalizing email addresses
#   email = NormalizingHelper.normalize_email_address("  USER@EXAMPLE.COM  ")
#   # => "user@example.com"
#
# @example Normalizing role names
#   role = NormalizingHelper.normalize_role_name("  admin user  ")
#   # => "Admin User"
#
module Securial
  module Helpers
    # Provides data normalization methods for common input sanitization.
    #
    # This module contains methods to normalize various types of user input
    # to ensure data consistency and prevent common formatting issues that
    # could lead to duplicate records or authentication problems.
    #
    module NormalizingHelper
      extend self

      # Normalizes an email address for consistent storage and comparison.
      #
      # Strips whitespace and converts to lowercase to ensure email addresses
      # are stored consistently regardless of how users input them. This prevents
      # duplicate accounts and authentication issues caused by case sensitivity.
      #
      # @param [String] email The email address to normalize
      # @return [String] The normalized email address, or empty string if input is empty
      #
      # @example Standard normalization
      #   normalize_email_address("  USER@EXAMPLE.COM  ")
      #   # => "user@example.com"
      #
      # @example Handling empty input
      #   normalize_email_address("")
      #   # => ""
      #
      # @example Preserving valid format
      #   normalize_email_address("user@example.com")
      #   # => "user@example.com"
      #
      def normalize_email_address(email)
        return "" if email.empty?

        email.strip.downcase
      end

      # Normalizes a role name for consistent display and storage.
      #
      # Strips whitespace, converts to lowercase, then applies title case formatting
      # to ensure role names are displayed consistently across the application.
      # This helps maintain a professional appearance and prevents formatting issues.
      #
      # @param [String] role_name The role name to normalize
      # @return [String] The normalized role name in title case, or empty string if input is empty
      #
      # @example Standard normalization
      #   normalize_role_name("  admin user  ")
      #   # => "Admin User"
      #
      # @example Handling mixed case input
      #   normalize_role_name("SUPER_ADMIN")
      #   # => "Super Admin"
      #
      # @example Handling empty input
      #   normalize_role_name("")
      #   # => ""
      #
      # @example Single word roles
      #   normalize_role_name("admin")
      #   # => "Admin"
      #
      def normalize_role_name(role_name)
        return "" if role_name.empty?

        role_name.strip.downcase.titleize
      end
    end
  end
end
