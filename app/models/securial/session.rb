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
      revoked? || expired? ? false : true
    end

    def refresh!
      raise Securial::Error::Auth::TokenRevokedError if revoked?
      raise Securial::Error::Auth::TokenExpiredError if expired?

      new_refresh_token = Securial::Auth::TokenGenerator.generate_refresh_token

      refresh_token_duration = Securial.configuration.session_refresh_token_expires_in

      update!(refresh_token: new_refresh_token,
              refresh_count: self.refresh_count + 1,
              last_refreshed_at: Time.current,
              refresh_token_expires_at: refresh_token_duration.from_now)
    end

    private

    def revoked?; revoked; end
    def expired?; refresh_token_expires_at < Time.current; end
  end
end
