module Securial
  #
  # PasswordResettable Concern
  #
  # This module provides functionality for managing password reset tokens and
  # password expiration for user accounts. It includes methods to generate,
  # validate, and clear reset password tokens, as well as to check if a user's
  # password has expired.
  #
  # It also includes validations for password complexity and length.
  #
  # ## Usage
  # Include this module in your User model to enable password reset functionality.
  # It requires the model to have a `password_digest` attribute for secure password storage.
  # The module also provides methods to handle password reset tokens and password expiration.
  #
  # ## Example
  #   class User < ApplicationRecord
  #     include Securial::PasswordResettable
  #     # Additional user model code...
  #   end
  #
  # ## Configuration
  # The module uses the Securial configuration for password complexity, length,
  # and reset password token expiration settings. You can configure these settings
  # in your Securial initializer.
  #
  # ## Validations
  # - Password must meet complexity requirements defined in Securial.configuration
  # - Password must be at least Securial.configuration.password_min_length characters long
  # - Password must be at most Securial.configuration.password_max_length characters long
  # - Password confirmation must be present if a new password is being set or if the password is not nil
  # - Reset password token must be generated and cleared appropriately
  # - Password expiration is managed based on the Securial.configuration.password_expires_in setting
  module PasswordResettable
    extend ActiveSupport::Concern

    included do
      has_secure_password

      before_save :update_password_changed_at, if: :will_save_change_to_password_digest?

      validates :password,
                length: {
                  minimum: Securial.configuration.password_min_length,
                  maximum: Securial.configuration.password_max_length,
                },
                format: {
                  with: Securial.configuration.password_complexity,
                  message: "must contain at least one uppercase letter, one lowercase letter, one digit, and one special character",
                },
                allow_nil: true

      validates :password_confirmation,
                presence: true,
                if: -> { new_record? || !password.nil? }
    end

    # Generates a secure reset password token for the user.
    #
    # @return [void] Updates the user's reset_password_token and reset_password_token_created_at attributes.
    def generate_reset_password_token!
      update!(
        reset_password_token: Auth::TokenGenerator.generate_password_reset_token,
        reset_password_token_created_at: Time.current
      )
    end

    # Checks if the reset password token is valid.
    #
    # The token is considered valid if it was created within the configured expiration duration.
    #
    # @example
    #   user.reset_password_token_valid? # => true or false
    # @note The method checks both the presence of the token and its creation time.
    # @note If the token is blank or the creation time is blank, it returns false.
    # @note If the token is expired, it returns false.
    # @note The method uses the configured expiration duration from Securial.configuration.
    # @return [Boolean] Returns true if the reset password token is valid, false otherwise.
    def reset_password_token_valid?
      return false if reset_password_token.blank? || reset_password_token_created_at.blank?

      duration = Securial.configuration.reset_password_token_expires_in
      return false unless duration.is_a?(ActiveSupport::Duration)

      reset_password_token_created_at > duration.ago
    end

    # Clears the reset password token and its creation time.
    #
    # This method is typically called after a successful password reset
    # to prevent the token from being reused.
    #
    # @return [void] Updates the user's reset_password_token and reset_password_token_created_at attributes to nil.
    def clear_reset_password_token!
      update!(
        reset_password_token: nil,
        reset_password_token_created_at: nil
      )
    end

    # Checks if the user's password has expired.
    #
    # The password is considered expired if the last time it was changed
    # is older than the configured expiration duration.
    #
    # @example
    #   user.password_expired? # => true or false
    # @note The method checks both the presence of the password_changed_at timestamp
    #   and the configured expiration duration.
    # @note If the password_changed_at timestamp is blank, it returns false.
    # @note If the password is expired, it returns true.
    # @return [Boolean] Returns true if the password is expired, false otherwise.
    def password_expired?
      return false unless Securial.configuration.password_expires
      return true unless password_changed_at

      password_changed_at < Securial.configuration.password_expires_in.ago
    end

    private

    # Updates the password_changed_at timestamp to the current time.
    #
    # This method is called before saving the user record if the password digest has changed.
    #
    # @return [void] Sets the password_changed_at attribute to the current time.
    def update_password_changed_at
      self.password_changed_at = Time.current
    end
  end
end
