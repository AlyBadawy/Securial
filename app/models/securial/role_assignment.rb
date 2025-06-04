module Securial
  class RoleAssignment < ApplicationRecord
    belongs_to :user
    belongs_to :role
  end
end
