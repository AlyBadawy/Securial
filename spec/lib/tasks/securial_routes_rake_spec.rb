require "rails_helper"
require "rake"

RSpec.describe "securial:routes rake task" do
  before do
    Rake.application.rake_require("tasks/securial_routes", [File.expand_path("../../../../lib", __FILE__)])
    Rake::Task.define_task(:environment)
  end

  let(:task_name) { "securial:routes" }

  it "prints all routes for the Securial engine" do
    # Use verifying doubles for the route structure
    path_double = instance_double(ActionDispatch::Journey::Path::Pattern, spec: "/foo/bar(.:format)")
    route_double = instance_double(
      ActionDispatch::Journey::Route,
      verb: "GET",
      path: path_double,
      name: "foo_bar",
      defaults: { controller: "foo", action: "bar" }
    )
    routes_double = instance_double(
      ActionDispatch::Routing::RouteSet,
      routes: [route_double]
    )
    engine_double = class_double(Securial::Engine).as_stubbed_const

    allow(Securial).to receive(:const_defined?).and_return(true)
    allow(engine_double).to receive(:routes).and_return(routes_double)

    Rake::Task[task_name].reenable
    expect {
      Rake::Task[task_name].invoke
    }.to output(/Routes for Securial::Engine:\n.*Verb\s+Path\s+Name\s+Controller#Action.*GET\s+\/foo\/bar\s+foo_bar\s+foo#bar/m).to_stdout
  end
end
