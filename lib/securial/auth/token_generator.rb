require "openssl"
require "securerandom"

module Securial
  module Auth
    module TokenGenerator
      class << self
        def generate_refresh_token
          secret = Securial.configuration.session_secret
          algo = "SHA256"

          random_data = SecureRandom.hex(32)
          digest = OpenSSL::Digest.new(algo)
          hmac = OpenSSL::HMAC.hexdigest(digest, secret, random_data)

          "#{hmac}#{random_data}"
        end

        def generate_password_reset_token
          chars = ("A".."Z").to_a + ("a".."z").to_a + ("0".."9").to_a
          token = Array.new(12) { chars.sample }.join
          "#{token[0, 6]}-#{token[6, 6]}"
        end
      end
    end
  end
end
