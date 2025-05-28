module Securial
  module AuthHelper
    class << self
      def encode(session)
        return nil unless session && session.class == Securial::Session

        base_payload = {
          jti: session.id,
          exp: expiry_duration.from_now.to_i,
          sub: "session-access-token",
          refresh_count: session.refresh_count,
        }

        session_payload = {
          ip: session.ip_address,
          agent: session.user_agent,
        }

        payload = base_payload.merge(session_payload)
        JWT.encode(payload, secret, algorithm, { kid: "hmac" })
      end

      def decode(token)
        decoded = JWT.decode(token, secret, true, { algorithm: algorithm, verify_jti: true, iss: "securial" })
        decoded.first
      end

      private

      def secret
        # Config::Validation.validate_session_secret!(Securial.configuration)
        Securial.configuration.session_secret
      end

      def algorithm
        # Config::Validation.validate_session_algorithm!(Securial.configuration)
        Securial.configuration.session_algorithm.to_s.upcase
      end

      def expiry_duration
        # Config::Validation.validate_session_expiry_duration!(Securial.configuration)
        Securial.configuration.session_expiration_duration
      end
    end
  end
end
