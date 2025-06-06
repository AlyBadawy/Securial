namespace :securial do
  desc "Print all routes for the Securial engine"
  task routes: :environment do
    engine = Securial::Engine
    routes = engine.routes

    puts "Routes for Securial::Engine:"
    all_routes = routes.routes.map do |route|
      {
        verb: route.verb,
        path: route.path.spec.to_s.gsub("(.:format)", ""),
        name: route.name,
        controller: route.defaults[:controller],
        action: route.defaults[:action],
      }
    end

    # Print in a table format with adjusted column widths
    puts "%-10s %-35s %-35s %-30s" % ["Verb", "Path", "Name", "Controller#Action"]
    puts "-" * 110
    all_routes.each do |r|
      ctrl_action = [r[:controller], r[:action]].compact.join("#")
      puts "%-10s %-35s %-35s %-30s" % [r[:verb], r[:path], r[:name], ctrl_action]
    end
  end
end
