module Securial
  module Auth
    module AuthEncoder
      module_function

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
        begin
          JWT.encode(payload, secret, algorithm, { kid: "hmac" })
        rescue JWT::EncodeError => e
          raise Errors::AuthEncodeError, "Failed to encode session: #{e.message}"
        end
      end

      def decode(token)
        begin
          decoded = JWT.decode(token, secret, true, { algorithm: algorithm, verify_jti: true, iss: "securial" })
        rescue JWT::DecodeError => e
          raise Securial::Auth::Errors::AuthDecodeError, "Failed to decode session token: #{e.message}"
        end
        decoded.first
      end

      def secret
        Securial.configuration.session_secret
      end

      def algorithm
        Securial.configuration.session_algorithm.to_s.upcase
      end

      def expiry_duration
        Securial.configuration.session_expiration_duration
      end

      private_class_method :secret, :algorithm, :expiry_duration
    end
  end
end
