module Securial
  #
  # User
  #
  # This class represents a user in the Securial authentication and authorization system.
  #
  # Users can have multiple roles assigned to them, which define their permissions
  # and access levels within the application.
  #
  # The User model includes functionality for password reset, email normalization,
  # and various validations to ensure data integrity.
  #
  # ## Attributes
  # - `email_address`: The user's email address, which is normalized
  # - `username`: A unique username for the user, with specific format requirements
  # - `first_name`: The user's first name, required and limited in length
  # - `last_name`: The user's last name, required and limited in length
  # - `phone`: An optional phone number, limited in length
  # - `bio`: An optional biography, limited in length
  #
  # ## Validations
  # - Email address must be present, unique, and formatted correctly
  # - Username must be present, unique (case insensitive), and formatted correctly
  # - First and last names must be present and limited in length
  # - Phone and bio fields are optional but have length restrictions
  #
  # ## Associations
  # - Has many role assignments, allowing users to have multiple roles
  # - Has many roles through role assignments, enabling flexible permission management
  # - Has many sessions, allowing for session management and tracking
  #
  class User < ApplicationRecord
    include Securial::PasswordResettable

    normalizes :email_address, with: ->(e) { Securial::Helpers::NormalizingHelper.normalize_email_address(e) }

    validates :email_address,
              presence: true,
              uniqueness: true,
              length: {
                minimum: 5,
                maximum: 255,
              },
              format: {
                with: Securial::Helpers::RegexHelper::EMAIL_REGEX,
                message: "must be a valid email address",
              }

    validates :username,
              presence: true,
              uniqueness: { case_sensitive: false },
              length: { maximum: 20 },
              format: {
                with: Securial::Helpers::RegexHelper::USERNAME_REGEX,
                message: "can only contain letters, numbers, underscores, and periods, but cannot start with a number or contain consecutive underscores or periods",
              }

    validates :first_name,
              presence: true,
              length: { maximum: 50 }
    validates :last_name,
              presence: true,
              length: { maximum: 50 }

    validates :phone,
              length: { maximum: 15 },
              allow_blank: true
    validates :bio,
              length: { maximum: 1000 },
              allow_blank: true

    has_many :role_assignments, dependent: :destroy
    has_many :roles, through: :role_assignments

    has_many :sessions, dependent: :destroy


    # Checks if the user has the specified role.
    #
    # @param [String] role_name The name of the role to check
    # @return [Boolean] Returns true if the user has the specified role, false otherwise.
    def is_admin?
      roles.exists?(role_name: Securial.titleized_admin_role)
    end
  end
end
