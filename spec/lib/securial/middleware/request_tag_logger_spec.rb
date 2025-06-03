require "rails_helper"

RSpec.describe Securial::Middleware::RequestTagLogger do
  let(:app) { instance_spy(Proc, call: [200, {}, ["OK"]]) }
  let(:logger) { instance_double(Securial::Logger::Broadcaster) }
  let(:middleware) { described_class.new(app, logger) }

  before { allow(logger).to receive(:tagged).and_yield }

  it "calls the app within logger.tagged with all tags" do
    env = {
      "action_dispatch.request_id" => "rid123",
      "action_dispatch.remote_ip" => "1.2.3.4",
      "HTTP_USER_AGENT" => "RSpec",
    }
    middleware.call(env)
    expect(logger).to have_received(:tagged).with("rid123", "IP:1.2.3.4", "UA:RSpec")
    expect(app).to have_received(:call).with(env)
  end

  it "falls back to HTTP_X_REQUEST_ID and REMOTE_ADDR" do
    env = {
      "HTTP_X_REQUEST_ID" => "rid456",
      "REMOTE_ADDR" => "5.6.7.8",
    }
    middleware.call(env)
    expect(logger).to have_received(:tagged).with("rid456", "IP:5.6.7.8")
  end

  it "skips missing tags gracefully" do
    env = {}
    middleware.call(env)
    expect(logger).to have_received(:tagged).with no_args
  end
end
