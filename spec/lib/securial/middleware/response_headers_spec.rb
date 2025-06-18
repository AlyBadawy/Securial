require "rails_helper"

RSpec.describe Securial::Middleware::ResponseHeaders do
  let(:app) do
    described_class.new(
      lambda { |_env|
        [200, { "Content-Type" => "text/plain" }, ["Hello"]]
      }
    )
  end

  let(:env) { {} }

  it "adds X-Securial-Mounted and X-Securial-Developer headers to the response" do
    status, headers, response = app.call(env)
    expect(status).to eq(200)
    expect(headers["X-Securial-Mounted"]).to eq("true")
    expect(headers["X-Securial-Developer"]).to eq("Aly Badawy - https://alybadawy.com | @alybadawy")
    expect(response).to eq(["Hello"])
  end

  it "preserves original headers" do
    _status, headers, _response = app.call(env)
    expect(headers["Content-Type"]).to eq("text/plain")
  end
end
