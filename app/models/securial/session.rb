module Securial
  class Session < ApplicationRecord
    belongs_to :user

    validates :ip_address, presence: true
    validates :user_agent, presence: true
    validates :refresh_token, presence: true

    def revoke!
      update!(revoked: true)
    end

    def is_valid_session?
      !revoked && refresh_token_expires_at > Time.current
    end

    def refresh!
      raise Securial::Sessions::Errors::SessionRevokedError, "Session is revoked" if revoked
      raise Securial::Sessions::Errors::SessionExpiredError, "Session is expired" if refresh_token_expires_at < Time.current

      update!(refresh_token: SecureRandom.hex(64),
              refresh_count: self.refresh_count + 1,
              last_refreshed_at: Time.current,
              refresh_token_expires_at: 1.week.from_now)
    end
  end
end
