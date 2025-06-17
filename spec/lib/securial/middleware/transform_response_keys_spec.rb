require "rails_helper"

RSpec.describe Securial::Middleware::TransformResponseKeys do
  let(:app) do
    described_class.new(
      ->(_env) {
        [
          200,
          { "Content-Type" => "application/json" },
          [response_body.to_json],
        ]
      }
    )
  end

  let(:env) { {} }
  let(:response_body) do
    {
      "my_key" => {
        "nested_key" => "value",
      },
      "another_key" => [
        { "inner_array_key" => 123 },
      ],
    }
  end

  before do
    allow(Securial).to receive(:configuration).and_return(
      object_double(response_keys_format: key_format)
    )
  end


  context "when response_keys_format is :lowerCamelCase" do
    let(:key_format) { :lowerCamelCase }

    it "transforms all keys to lowerCamelCase" do
      status, headers, response = app.call(env)
      body = JSON.parse(response.first)
      expect(body).to eq(
        "myKey" => { "nestedKey" => "value" },
        "anotherKey" => [{ "innerArrayKey" => 123 }]
      )
      expect(headers["Content-Length"]).to eq(response.first.bytesize.to_s)
      expect(status).to eq(200)
    end
  end

  context "when response_keys_format is :UpperCamelCase" do
    let(:key_format) { :UpperCamelCase }

    it "transforms all keys to UpperCamelCase" do
      status, headers, response = app.call(env)
      body = JSON.parse(response.first)
      expect(body).to eq(
        "MyKey" => { "NestedKey" => "value" },
        "AnotherKey" => [{ "InnerArrayKey" => 123 }]
      )
    end
  end

  context "when response is not JSON" do
    let(:key_format) { :lowerCamelCase }
    let(:app) do
      described_class.new(
        ->(_env) {
          [
            200,
            { "Content-Type" => "text/html" },
            ["<html></html>"],
          ]
        }
      )
    end

    it "does not transform the response" do
      status, headers, response = app.call(env)
      expect(response.first).to eq("<html></html>")
      expect(headers["Content-Type"]).to eq("text/html")
    end
  end

  context "when JSON body is empty" do
    let(:key_format) { :lowerCamelCase }
    let(:app) do
      described_class.new(
        ->(_env) {
          [
            200,
            { "Content-Type" => "application/json" },
            [""],
          ]
        }
      )
    end

    it "returns the response unchanged" do
      _status, _headers, response = app.call(env)
      expect(response.first).to eq("")
    end
  end
end
