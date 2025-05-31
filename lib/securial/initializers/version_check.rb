require "net/http"
require "json"

module Securial
  module VersionCheck
    RUBYGEMS_API_URL = "https://rubygems.org/api/v1/versions/securial/latest.json"

    def self.check_latest_version # rubocop:disable Metrics/MethodLength
      begin
        uri = URI(RUBYGEMS_API_URL)
        http = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 5)
        response = http.request(Net::HTTP::Get.new(uri))
        latest = JSON.parse(response)["version"]

        current = Securial::VERSION
        if Gem::Version.new(latest) > Gem::Version.new(current)
          Securial.logger.info "A newer version (#{latest}) of Securial is available. You are using #{current}."
          Securial.logger.info "Please consider updating!"
          Securial.logger.debug "You can update Securial by running the following command in your terminal:"
          Securial.logger.debug "`bundle update securial`"
        else
          Securial.logger.info "You are using the latest version of Securial (#{current})."
          Securial.logger.debug "No updates available at this time."
        end
      rescue => e
        Securial.logger.debug("Version check failed: #{e.message}")
      end
    end
  end
end
