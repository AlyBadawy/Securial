module Securial
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


    def is_admin?
      roles.exists?(role_name: Securial.titleized_admin_role)
    end
  end
end
