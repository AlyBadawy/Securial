module Securial
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

    def generate_reset_password_token!
      update!(
        reset_password_token: Auth::TokenGenerator.generate_password_reset_token,
        reset_password_token_created_at: Time.current
      )
    end

    def reset_password_token_valid?
      return false if reset_password_token.blank? || reset_password_token_created_at.blank?

      duration = Securial.configuration.reset_password_token_expires_in
      return false unless duration.is_a?(ActiveSupport::Duration)

      reset_password_token_created_at > duration.ago
    end

    def clear_reset_password_token!
      update!(
        reset_password_token: nil,
        reset_password_token_created_at: nil
      )
    end

    def password_expired?
      return false unless Securial.configuration.password_expires
      return true unless password_changed_at

      password_changed_at < Securial.configuration.password_expires_in.ago
    end

    private

    def update_password_changed_at
      self.password_changed_at = Time.current
    end
  end
end
