module Securial
  class Role < ApplicationRecord
    normalizes :role_name, with: ->(e) { Securial::Helpers::NormalizingHelper.normalize_role_name(e) }

    validates :role_name, presence: true, uniqueness: { case_sensitive: false }

    # has_many :role_assignments, dependent: :destroy
    # has_many :users, through: :role_assignments
  end
end
