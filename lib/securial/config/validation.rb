require "securial/logger"

module Securial
  module Config
    module Validation
      class << self # rubocop:disable Metrics/ClassLength
        def validate_all!(config)
          validate_admin_role!(config)
          validate_session_config!(config)
          validate_mailer_sender!(config)
          validate_password_config!(config)
          validate_response_config!(config)
          validate_security_config!(config)
        end

        private

        def validate_admin_role!(config)
          if config.admin_role.nil? || config.admin_role.to_s.strip.empty?
            error_message = "Admin role is not set."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigAdminRoleError, error_message
          end

          unless config.admin_role.is_a?(Symbol) || config.admin_role.is_a?(String)
            error_message = "Admin role must be a Symbol or String."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigAdminRoleError, error_message
          end

          if config.admin_role.to_s.pluralize.downcase == "accounts"
            error_message = "The admin role cannot be 'account' or 'accounts' as it conflicts with the default routes."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigAdminRoleError, error_message
          end
        end

        def validate_session_config!(config)
          validate_session_expiry_duration!(config)
          validate_session_algorithm!(config)
          validate_session_secret!(config)
        end

        def validate_session_expiry_duration!(config)
          if config.session_expiration_duration.nil?
            error_message = "Session expiration duration is not set."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSessionExpirationDurationError, error_message
          end
          if config.session_expiration_duration.class != ActiveSupport::Duration
            error_message = "Session expiration duration must be an ActiveSupport::Duration."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSessionExpirationDurationError, error_message
          end
          if config.session_expiration_duration <= 0
            Securial::ENGINE_LOGGER.error("Session expiration duration must be greater than 0.")
            raise Securial::Config::Errors::ConfigSessionExpirationDurationError, "Session expiration duration must be greater than 0."
          end
        end

        def validate_session_algorithm!(config)
          if config.session_algorithm.blank?
            error_message = "Session algorithm is not set."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSessionAlgorithmError, error_message
          end
          unless config.session_algorithm.is_a?(Symbol)
            error_message = "Session algorithm must be a Symbol."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSessionAlgorithmError, error_message
          end
          valid_algorithms = Securial::Config::VALID_SESSION_ENCRYPTION_ALGORITHMS
          unless valid_algorithms.include?(config.session_algorithm)
            error_message = "Invalid session algorithm. Valid options are: #{valid_algorithms.map(&:inspect).join(', ')}."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSessionAlgorithmError, error_message
          end
        end

        def validate_session_secret!(config)
          if config.session_secret.blank?
            error_message = "Session secret is not set."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSessionSecretError, error_message
          end
          unless config.session_secret.is_a?(String)
            error_message = "Session secret must be a String."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSessionSecretError, error_message
          end
        end

        def validate_mailer_sender!(config)
          if config.mailer_sender.blank?
            error_message = "Mailer sender is not set."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigMailerSenderError, error_message
          end
          if config.mailer_sender !~  URI::MailTo::EMAIL_REGEXP
            error_message = "Mailer sender is not a valid email address."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigMailerSenderError, error_message
          end
        end

        def validate_password_config!(config)
          validate_password_reset_subject!(config)
          validate_password_min_max_length!(config)
          validate_password_complexity!(config)
          validate_password_expiration!(config)
          validate_password_reset_token!(config)
        end

        def validate_password_reset_token!(config)
          if config.reset_password_token_secret.blank?
            error_message = "Reset password token secret is not set."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end
          unless config.reset_password_token_secret.is_a?(String)
            error_message = "Reset password token secret must be a String."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end
        end

        def validate_password_reset_subject!(config)
          if config.password_reset_email_subject.blank?
            error_message = "Password reset email subject is not set."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end
          unless config.password_reset_email_subject.is_a?(String)
            error_message = "Password reset email subject must be a String."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end
        end

        def validate_password_min_max_length!(config)
          unless config.password_min_length.is_a?(Integer) && config.password_min_length > 0
            error_message = "Password minimum length must be a positive integer."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end
          unless config.password_max_length.is_a?(Integer) && config.password_max_length >= config.password_min_length
            error_message = "Password maximum length must be an integer greater than or equal to the minimum length."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end
        end

        def validate_password_complexity!(config)
          if config.password_complexity.nil? || !config.password_complexity.is_a?(Regexp)
            error_message = "Password complexity regex is not set or is not a valid Regexp."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end
        end

        def validate_password_expiration!(config)
          unless config.password_expires.is_a?(TrueClass) || config.password_expires.is_a?(FalseClass)
            error_message = "Password expiration must be a boolean value."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end

          if config.password_expires == true && (
              config.password_expires_in.nil? ||
              !config.password_expires_in.is_a?(ActiveSupport::Duration) ||
              config.password_expires_in <= 0
            )
            error_message = "Password expiration duration is not set or is not a valid ActiveSupport::Duration."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigPasswordError, error_message
          end
        end

        def validate_response_config!(config)
          validate_response_keys_format!(config)
          validate_timestamps_in_response!(config)
        end

        def validate_response_keys_format!(config)
          valid_formats = Securial::Config::VALID_RESPONSE_KEYS_FORMATS
          unless valid_formats.include?(config.response_keys_format)
            error_message = "Invalid response_keys_format option. Valid options are: #{valid_formats.map(&:inspect).join(', ')}."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigResponseError, error_message
          end
        end

        def validate_timestamps_in_response!(config)
          valid_options = Securial::Config::VALID_TIMESTAMP_OPTIONS
          unless valid_options.include?(config.timestamps_in_response)
            error_message = "Invalid timestamps_in_response option. Valid options are: #{valid_options.map(&:inspect).join(', ')}."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigResponseError, error_message
          end
        end

        def validate_security_config!(config)
          validate_security_headers!(config)
          validate_rate_limiting!(config)
        end

        def validate_security_headers!(config)
          valid_options = Securial::Config::VALID_SECURITY_HEADERS
          unless valid_options.include?(config.security_headers)
            error_message = "Invalid security_headers option. Valid options are: #{valid_options.map(&:inspect).join(', ')}."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSecurityError, error_message
          end
        end

        def validate_rate_limiting!(config) # rubocop:disable Metrics/MethodLength
          unless config.enable_rate_limiting.is_a?(TrueClass) || config.enable_rate_limiting.is_a?(FalseClass)
            error_message = "enable_rate_limiting must be a boolean value."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSecurityError, error_message
          end

          return unless config.enable_rate_limiting

          unless
              config.rate_limit_requests_per_minute.is_a?(Integer) &&
              config.rate_limit_requests_per_minute > 0

            error_message = "rate_limit_requests_per_minute must be a positive integer when rate limiting is enabled."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSecurityError, error_message
          end

          unless config.rate_limit_response_status.is_a?(Integer) && config.rate_limit_response_status.between?(400, 599)
            error_message = "rate_limit_response_status must be an HTTP status code between 4xx and 5xx."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSecurityError, error_message
          end

          unless config.rate_limit_response_message.is_a?(String) && !config.rate_limit_response_message.strip.empty?
            error_message = "rate_limit_response_message must be a non-empty String."
            Securial::ENGINE_LOGGER.error(error_message)
            raise Securial::Config::Errors::ConfigSecurityError, error_message
          end
        end
      end
    end
  end
end
