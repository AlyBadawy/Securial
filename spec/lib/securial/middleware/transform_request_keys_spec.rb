require "rails_helper"

RSpec.describe Securial::Middleware::TransformRequestKeys do
  let(:app) do
    described_class.new(
      lambda { |env|
        req = Rack::Request.new(env)
        body = req.body.read
        req.body.rewind
        [200, { "Content-Type" => "application/json" }, [body]]
      }
    )
  end

  def post_json(path, json)
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => path,
      "CONTENT_TYPE" => "application/json",
      "rack.input" => StringIO.new(json),
    }
    app.call(env)
  end

  it "transforms camelCase request keys to underscore" do
    payload = { "myKey" => { "nestedKey" => "value" }, "arrayKey" => [{ "innerArrayKey" => 1 }] }
    status, _headers, response = post_json("/test", payload.to_json)
    result = JSON.parse(response.first)
    expect(result).to eq(
      "my_key" => { "nested_key" => "value" },
      "array_key" => [{ "inner_array_key" => 1 }]
    )
    expect(status).to eq(200)
  end

  it "leaves already underscored keys unchanged" do
    payload = { "already_underscored" => "value" }
    status, _headers, response = post_json("/test", payload.to_json)
    result = JSON.parse(response.first)
    expect(result).to eq("already_underscored" => "value")
    expect(status).to eq(200)
  end

  it "does nothing if body is not valid JSON" do
    status, _headers, response = post_json("/test", "{not: 'json'}")
    expect(response.first).to eq("{not: 'json'}")
    expect(status).to eq(200)
  end

  it "does nothing if content type is not JSON" do
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/test",
      "CONTENT_TYPE" => "text/plain",
      "rack.input" => StringIO.new("plain text"),
    }
    status, _headers, response = app.call(env)
    expect(response.first).to eq("plain text")
    expect(status).to eq(200)
  end

  it "does nothing if body is empty" do
    env = {
      "REQUEST_METHOD" => "POST",
      "PATH_INFO" => "/test",
      "CONTENT_TYPE" => "application/json",
      "rack.input" => StringIO.new(""),
    }
    status, _headers, response = app.call(env)
    expect(response.first).to eq("")
    expect(status).to eq(200)
  end
end
