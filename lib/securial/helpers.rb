# @title Securial Helper Utilities
#
# Centralized collection of helper modules for the Securial framework.
#
# This file serves as the entry point for all helper functionality in Securial,
# loading specialized utility modules that provide common functions used
# throughout the framework. These helpers handle tasks such as normalization,
# pattern matching, role management, and data transformation, making common
# operations consistent across the codebase.
#
# @example Normalizing user input
#   # For normalizing email addresses (converts to lowercase)
#   email = Securial::Helpers::NormalizingHelper.normalize_email("USER@EXAMPLE.COM")
#   # => "user@example.com"
#
# @example Validating input format
#   # For validating email format
#   valid = Securial::Helpers::RegexHelper.valid_email?("user@example.com")
#   # => true
#
#   invalid = Securial::Helpers::RegexHelper.valid_email?("not-an-email")
#   # => false
#
# @example Transforming data structure keys
#   # For transforming keys in response data (snake_case to camelCase)
#   data = { user_id: 1, first_name: "John", last_name: "Doe" }
#   json = Securial::Helpers::KeyTransformer.transform(data, :lower_camel_case)
#   # => { userId: 1, firstName: "John", lastName: "Doe" }
#
require "securial/helpers/normalizing_helper"
require "securial/helpers/regex_helper"
require "securial/helpers/roles_helper"
require "securial/helpers/key_transformer"

module Securial
  # Namespace containing utility modules for common operations.
  #
  # The Helpers module serves as a container for specialized utility modules
  # that provide reusable functionality across the Securial framework:
  #
  # - {NormalizingHelper} - Methods for normalizing user input (emails, usernames, etc.)
  # - {RegexHelper} - Regular expressions and validation methods for input validation
  # - {RolesHelper} - Functions for working with user roles and permissions management
  # - {KeyTransformer} - Tools for transforming data structure keys between formats (snake_case, camelCase)
  #
  # These helpers ensure consistent behavior across the application and reduce
  # code duplication by centralizing common operations.
  #
  # @see Securial::Helpers::NormalizingHelper
  # @see Securial::Helpers::RegexHelper
  # @see Securial::Helpers::RolesHelper
  # @see Securial::Helpers::KeyTransformer
  #
  module Helpers; end
end
