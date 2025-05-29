module Securial
  module Config
    VALID_SESSION_ENCRYPTION_ALGORITHMS = [:hs256, :hs384, :hs512].freeze
    VALID_TIMESTAMP_OPTIONS = [:all, :admins_only, :none].freeze

    class Configuration
      attr_accessor :log_to_file, :log_to_stdout
      attr_accessor :log_file_level, :log_stdout_level
      attr_accessor :admin_role
      attr_accessor :session_expiration_duration
      attr_accessor :session_secret, :session_algorithm
      attr_accessor :mailer_sender
      attr_accessor :password_reset_email_subject
      attr_accessor :password_min_length, :password_max_length
      attr_accessor :password_complexity
      attr_accessor :password_expires, :password_expires_in
      attr_accessor :reset_password_token_expires_in
      attr_accessor :reset_password_token_secret
      attr_accessor :timestamps_in_response

      def initialize
        @log_to_file = !Rails.env.test?
        @log_to_stdout = !Rails.env.test?
        @log_file_level = :info
        @log_stdout_level = :info
        @admin_role = :admin
        @session_expiration_duration = 3.minutes
        @session_secret = "secret"
        @session_algorithm = :hs256
        @mailer_sender = "no-reply@example.com"
        @password_reset_email_subject = "SECURIAL: Password Reset Instructions"
        @password_min_length = 8
        @password_max_length = 128
        @password_complexity = Securial::RegexHelper::PASSWORD_REGEX
        @password_expires = true
        @password_expires_in = 90.days
        @reset_password_token_expires_in = 2.hours
        @reset_password_token_secret = "reset_secret"
        @timestamps_in_response = :all
      end
    end
  end
end
