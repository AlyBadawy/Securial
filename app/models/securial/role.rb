module Securial
  #
  # Role
  #
  # This class represents a role in the Securial authorization system.
  #
  # Roles are used to define permissions and access levels for users within the application.
  #
  # ## Attributes
  # - `role_name`: The name of the role, which is normalized to ensure consistency.
  #
  # ## Validations
  # - `role_name` must be present and unique (case insensitive).
  #
  # ## Associations
  # - Has many role assignments, allowing users to be associated with this role
  # - Has many users through role assignments, enabling flexible permission management
  #
  class Role < ApplicationRecord
    normalizes :role_name, with: ->(e) { Securial::Helpers::NormalizingHelper.normalize_role_name(e) }

    validates :role_name, presence: true, uniqueness: { case_sensitive: false }

    has_many :role_assignments, dependent: :destroy
    has_many :users, through: :role_assignments
  end
end
