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
      end
    end
  end
end
