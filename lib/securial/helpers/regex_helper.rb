# @title Securial Regex Helpers
#
# Regular expression utilities for data validation in the Securial framework.
#
# This module provides commonly used regular expressions and validation methods
# for user input such as email addresses, usernames, and passwords. It ensures
# consistent validation rules across the application and helps maintain data
# integrity and security standards.
#
# @example Validating an email address
#   RegexHelper.valid_email?("user@example.com")
#   # => true
#
# @example Validating a username
#   RegexHelper.valid_username?("john_doe123")
#   # => true
#
# @example Checking password complexity
#   password = "MyPass123!"
#   password.match?(RegexHelper::PASSWORD_REGEX)
#   # => true
#
require "uri"

module Securial
  module Helpers
    # Regular expression patterns and validation methods for common data types.
    #
    # This module centralizes regex patterns used throughout Securial for
    # validating user input. It provides both the raw regex patterns as
    # constants and convenience methods for validation.
    #
    module RegexHelper
      # RFC-compliant email address validation pattern.
      #
      # Uses Ruby's built-in URI::MailTo::EMAIL_REGEXP which follows RFC 3696
      # specifications for email address validation.
      #
      # @return [Regexp] Email validation regular expression
      #
      EMAIL_REGEX = URI::MailTo::EMAIL_REGEXP

      # Username validation pattern with specific formatting rules.
      #
      # Enforces the following username requirements:
      # - Must start with a letter (not a number)
      # - Can contain letters, numbers, periods, and underscores
      # - Cannot have consecutive periods or underscores
      # - Must end with a letter or number
      # - Minimum length of 2 characters
      #
      # @return [Regexp] Username validation regular expression
      #
      USERNAME_REGEX = /\A(?![0-9])[a-zA-Z](?:[a-zA-Z0-9]|[._](?![._]))*[a-zA-Z0-9]\z/

      # Password complexity validation pattern.
      #
      # Enforces strong password requirements including:
      # - At least one digit (0-9)
      # - At least one lowercase letter (a-z)
      # - At least one uppercase letter (A-Z)
      # - At least one special character (non-alphanumeric)
      # - Must start with a letter
      #
      # @return [Regexp] Password complexity validation regular expression
      #
      PASSWORD_REGEX = %r{\A(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[^a-zA-Z0-9])[a-zA-Z].*\z}

      extend self

      # Validates if an email address matches the RFC-compliant pattern.
      #
      # Uses the EMAIL_REGEX pattern to check if the provided email address
      # follows proper email formatting standards.
      #
      # @param [String] email The email address to validate
      # @return [Boolean] true if the email is valid, false otherwise
      #
      # @example Valid email addresses
      #   valid_email?("user@example.com")        # => true
      #   valid_email?("test.email@domain.co.uk") # => true
      #   valid_email?("user+tag@example.org")    # => true
      #
      # @example Invalid email addresses
      #   valid_email?("invalid.email")           # => false
      #   valid_email?("@example.com")            # => false
      #   valid_email?("user@")                   # => false
      #
      def valid_email?(email)
        email.match?(EMAIL_REGEX)
      end

      # Validates if a username follows the defined formatting rules.
      #
      # Uses the USERNAME_REGEX pattern to check if the provided username
      # meets the application's username requirements.
      #
      # @param [String] username The username to validate
      # @return [Boolean] true if the username is valid, false otherwise
      #
      # @example Valid usernames
      #   valid_username?("john_doe")      # => true
      #   valid_username?("user123")       # => true
      #   valid_username?("test.user")     # => true
      #   valid_username?("a1")            # => true
      #
      # @example Invalid usernames
      #   valid_username?("123user")       # => false (starts with number)
      #   valid_username?("user__name")    # => false (consecutive underscores)
      #   valid_username?("user.")         # => false (ends with period)
      #   valid_username?("a")             # => false (too short)
      #
      def valid_username?(username)
        username.match?(USERNAME_REGEX)
      end

      # Validates if a password meets complexity requirements.
      #
      # Uses the PASSWORD_REGEX pattern to check if the provided password
      # meets the application's security standards.
      #
      # @param [String] password The password to validate
      # @return [Boolean] true if the password meets complexity requirements, false otherwise
      #
      # @example Valid passwords
      #   valid_password?("MyPass123!")    # => true
      #   valid_password?("Secure@2024")   # => true
      #   valid_password?("aB3#defgh")     # => true
      #
      # @example Invalid passwords
      #   valid_password?("password")      # => false (no uppercase, number, or special char)
      #   valid_password?("PASSWORD123")   # => false (no lowercase or special char)
      #   valid_password?("123Password!")  # => false (starts with number)
      #
      def valid_password?(password)
        password.match?(PASSWORD_REGEX)
      end
    end
  end
end
