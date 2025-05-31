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
          Securial.logger.debug "Securial engine routes:"
          Securial.logger.debug "Total routes: #{filtered.size}"
          Securial.logger.debug "Filtered by controller: #{controller}" if controller
          Securial.logger.debug "Filtered routes: #{filtered.size}" if controller
          Securial.logger.debug "-" * 120
          Securial.logger.debug "#{'Verb'.ljust(8)} #{'Path'.ljust(45)} #{'Controller#Action'.ljust(40)} Name"
          Securial.logger.debug "-" * 120
        end

        def print_details(filtered, controller) # rubocop:disable Rails/Output
          if filtered.empty?
            if controller
              Securial.logger.debug "No routes found for controller: #{controller}"
            else
              Securial.logger.debug "No routes found for Securial engine"
            end
            Securial.logger.debug "-" * 120
            return
          end

          Securial.logger.debug filtered.map { |r|
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
