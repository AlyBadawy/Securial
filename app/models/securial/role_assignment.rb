module Securial
  #
  # RoleAssignment
  #
  # This class represents the association between a user and a role in the Securial system.
  #
  # It is used to manage which roles are assigned to which users, allowing for
  # flexible permission management within the application.
  #
  ### Attributes
  # - `user_id`: The ID of the user to whom the role is assigned
  # - `role_id`: The ID of the role being assigned to the user
  #
  # ## Associations
  # - Belongs to a user, linking the assignment to a specific user
  # - Belongs to a role, linking the assignment to a specific role
  #
  class RoleAssignment < ApplicationRecord
    belongs_to :user
    belongs_to :role
  end
end
