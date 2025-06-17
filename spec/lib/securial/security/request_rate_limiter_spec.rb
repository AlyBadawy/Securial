require "rails_helper"
require 'ostruct'

RSpec.describe Securial::Security::RequestRateLimiter do
  let(:app) do
    Rack::Builder.new do
      use Rack::Attack
      run ->(env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] }
    end
  end

  let(:email) { "test@example.com" }
  let(:ip) { "1.2.3.4" }
  let(:request_path) { "/sessions/login" }
  let(:forgot_path) { "/password/forgot" }

  before do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    # Stub configuration
    allow(Securial.configuration).to receive_messages(rate_limit_requests_per_minute: 1, rate_limit_response_status: 429, rate_limit_response_message: "Rate limit exceeded")

    # Reset Rack::Attack configuration
    Rack::Attack.reset!
    described_class.apply!
  end

  it "throttles login attempts by IP" do
    2.times do
      post request_path, params: { email_address: email }, headers: { "REMOTE_ADDR" => ip }
    end
    expect(response.status).to eq(429)
    expect(JSON.parse(response.body)["error"]).to eq("Rate limit exceeded")
    expect(response.headers["Retry-After"]).to eq("60")
  end

  it "throttles login attempts by email" do
    2.times do
      post request_path, params: { email_address: email }, headers: { "REMOTE_ADDR" => "5.6.7.8" }
    end
    expect(response.status).to eq(429)
    expect(JSON.parse(response.body)["error"]).to eq("Rate limit exceeded")
  end

  it "throttles password reset by IP" do
    2.times do
      post forgot_path, params: { email_address: email }, headers: { "REMOTE_ADDR" => ip }
    end
    expect(response.status).to eq(429)
    expect(JSON.parse(response.body)["error"]).to eq("Rate limit exceeded")
  end

  it "throttles password reset by email" do
    2.times do
      post forgot_path, params: { email_address: email }, headers: { "REMOTE_ADDR" => "9.9.9.9" }
    end
    expect(response.status).to eq(429)
    expect(JSON.parse(response.body)["error"]).to eq("Rate limit exceeded")
  end

  def post(path, params:, headers:)
    env = Rack::MockRequest.env_for(path,
                                    method: "POST",
                                    params: params,
                                    "REMOTE_ADDR" => headers["REMOTE_ADDR"]
    )
    status, headers, body = app.call(env)
    @last_response = OpenStruct.new(
      status: status,
      headers: headers,
      body: body.first
    )
  end

  def response
    @last_response
  end
end
