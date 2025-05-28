module Securial
  module Inspectors
    module RouteInspector
      def self.print_routes(controller: nil)
        filtered = Securial::Engine.routes.routes.select do |r|
          ctrl = r.defaults[:controller]
          controller.nil? || ctrl == "securial/#{controller}"
        end

        print_headers(filtered, controller)
        print_details(filtered, controller)
        true
      end

      class << self
        private

        # rubocop:disable Rails/Output
        def print_headers(filtered, controller)
          Securial::ENGINE_LOGGER.debug "Securial engine routes:"
          Securial::ENGINE_LOGGER.debug "Total routes: #{filtered.size}"
          Securial::ENGINE_LOGGER.debug "Filtered by controller: #{controller}" if controller
          Securial::ENGINE_LOGGER.debug "Filtered routes: #{filtered.size}" if controller
          Securial::ENGINE_LOGGER.debug "-" * 120
          Securial::ENGINE_LOGGER.debug "#{'Verb'.ljust(8)} #{'Path'.ljust(45)} #{'Controller#Action'.ljust(40)} Name"
          Securial::ENGINE_LOGGER.debug "-" * 120
        end

        def print_details(filtered, controller) # rubocop:disable Rails/Output
          if filtered.empty?
            if controller
              Securial::ENGINE_LOGGER.debug "No routes found for controller: #{controller}"
            else
              Securial::ENGINE_LOGGER.debug "No routes found for Securial engine"
            end
            Securial::ENGINE_LOGGER.debug "-" * 120
            return
          end

          Securial::ENGINE_LOGGER.debug filtered.map { |r|
            name = r.name || ""
            verb = r.verb.to_s.ljust(8)
            path = r.path.spec.to_s.sub(/\(\.:format\)/, "").ljust(45)
            ctrl_action = "#{r.defaults[:controller]}##{r.defaults[:action]}"
            "#{verb} #{path} #{ctrl_action.ljust(40)} #{name}"
          }.join("\n")
        end
        # rubocop:enable Rails/Output
      end
    end
  end
end
