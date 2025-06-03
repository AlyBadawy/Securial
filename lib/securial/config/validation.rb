require "securial/logger"
require "securial/config/validation/logger_validation"

module Securial
  module Config
    module Validation
      class << self
        def validate_all!(config)
          Securial::Config::Validation::LoggerValidation.validate!(config)
        end
      end
    end
  end
end
