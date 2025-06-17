require "rails_helper"

RSpec.describe Securial::Helpers::KeyTransformer do
  describe ".camelize" do
    it "camelizes to lowerCamelCase" do
      expect(described_class.camelize("my_key_name", :lowerCamelCase)).to eq("myKeyName")
    end

    it "camelizes to UpperCamelCase" do
      expect(described_class.camelize("my_key_name", :UpperCamelCase)).to eq("MyKeyName")
    end

    it "returns string as-is for unknown format" do
      expect(described_class.camelize("my_key_name", :snake_case)).to eq("my_key_name")
    end
  end

  describe ".underscore" do
    it "underscores a camelCase string" do
      expect(described_class.underscore("myKeyName")).to eq("my_key_name")
    end

    it "underscores an UpperCamelCase string" do
      expect(described_class.underscore("MyKeyName")).to eq("my_key_name")
    end
  end

  describe ".deep_transform_keys" do
    it "transforms keys deeply in a hash" do
      hash = { "MyKey" => { "InnerKey" => "value" }, "list" => [{ "AnotherKey" => 1 }] }
      result = described_class.deep_transform_keys(hash) { |key| described_class.underscore(key) }
      expect(result).to eq({ "my_key" => { "inner_key" => "value" }, "list" => [{ "another_key" => 1 }] })
    end

    it "transforms keys deeply in an array" do
      arr = [{ "MyKey" => "val" }, { "AnotherKey" => "val2" }]
      result = described_class.deep_transform_keys(arr) { |key| key.downcase }
      expect(result).to eq([{ "mykey" => "val" }, { "anotherkey" => "val2" }])
    end

    it "returns primitive values as-is" do
      expect(described_class.deep_transform_keys("string") { |k| k }).to eq("string")
      expect(described_class.deep_transform_keys(123) { |k| k }).to eq(123)
    end
  end
end
