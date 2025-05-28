require "securial/version"
require "securial/engine"

require "jbuilder"

module Securial
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      validate_admin_role!
      validate_session_expiry_duration!
      validate_session_algorithm!
      validate_session_secret!
      validate_mailer_sender!
      validate_password_config!
      validate_timestamps_in_response!
    end

    # Returns the pluralized form of the admin role.
    # This behavior is intentional and aligns with the project's routing conventions.
    def admin_namespace
      configuration.admin_role.to_s.pluralize.downcase
    end

    def validate_admin_role!
      error_message = "The admin role cannot be 'account' or 'accounts' as it conflicts with the default routes."

      if configuration.admin_role.to_s.pluralize.downcase == "accounts"
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigAdminRoleError, error_message
      end
    end

    def validate_session_expiry_duration!
      if configuration.session_expiration_duration.nil?
        error_message = "Session expiration duration is not set."
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigSessionExpirationDurationError, error_message
      end
      if configuration.session_expiration_duration.class != ActiveSupport::Duration
        error_message = "Session expiration duration must be an ActiveSupport::Duration."
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigSessionExpirationDurationError, error_message
      end
      if configuration.session_expiration_duration <= 0
        Securial::ENGINE_LOGGER.error("Session expiration duration must be greater than 0.")
        raise Securial::ConfigErrors::ConfigSessionExpirationDurationError, "Session expiration duration must be greater than 0."
      end
    end

    def validate_session_algorithm!
      valid_algorithms = [:hs256, :hs384, :hs512]
      unless valid_algorithms.include?(configuration.session_algorithm)
        error_message = "Invalid session algorithm. Valid options are: #{valid_algorithms.map(&:inspect).join(', ')}."
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigSessionAlgorithmError, error_message
      end
    end

    def validate_session_secret!
      if configuration.session_secret.blank?
        error_message = "Session secret is not set."
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigSessionSecretError, error_message
      end
    end

    def validate_mailer_sender!
      if configuration.mailer_sender.blank?
        error_message = "Mailer sender is not set."
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigMailerSenderError, error_message
      end
      if configuration.mailer_sender !~  URI::MailTo::EMAIL_REGEXP
        error_message = "Mailer sender is not a valid email address."
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigMailerSenderError, error_message
      end
    end

    def validate_password_config!
      if configuration.password_reset_email_subject.blank?
        error_message = "Password reset email subject is not set."
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigMailerSenderError, error_message
      end
    end

    def validate_timestamps_in_response!
      valid_options = [:all, :admins_only, :none]
      unless valid_options.include?(configuration.timestamps_in_response)
        error_message = "Invalid timestamps_in_response option. Valid options are: #{valid_options.map(&:inspect).join(', ')}."
        Securial::ENGINE_LOGGER.error(error_message)
        raise Securial::ConfigErrors::ConfigTimestampsInResponseError, error_message
      end
    end
  end
end
