require "rails_helper"

RSpec.describe Securial::StatusController, type: :routing do
  it "routes /securial/status to the securial/status#show action" do
    expect(get: "/securial/status").to route_to(
      controller: "securial/status",
      action: "show",
      format: :json,
    )
  end
end
