require "rails_helper"
require "generators/factory_bot/model/model_generator"
require "fileutils"

RSpec.describe FactoryBot::Generators::ModelGenerator do
  let(:model_name) { "user" }
  let(:attributes) { [] }
  let(:generator) { described_class.new([model_name] + attributes) }
  let(:destination_root) { File.expand_path("../../../tmp", __dir__) }

  before do
    # Set up destination directory for generated files
    FileUtils.mkdir_p(destination_root)
    generator.destination_root = destination_root
    allow(generator).to receive(:template)
  end

  describe "#securial_attribute_defaults" do
    subject(:defaults) { generator.securial_attribute_defaults }

    it "returns a hash with 9 attribute types" do
      expect(defaults.keys.size).to eq(9)
    end

    it "returns the correct default values" do # rubocop:disable RSpec/MultipleExpectations
      expect(defaults[:string]).to eq('"MyString"')
      expect(defaults[:text]).to eq('"MyText"')
      expect(defaults[:integer]).to eq("1")
      expect(defaults[:float]).to eq("1.5")
      expect(defaults[:decimal]).to eq('"9.99"')
      expect(defaults[:datetime]).to eq("Time.zone.now")
      expect(defaults[:time]).to eq("Time.zone.now")
      expect(defaults[:date]).to eq("Time.zone.now")
      expect(defaults[:boolean]).to eq("false")
    end

    it "returns a fresh hash each time it's called" do
      first_defaults = generator.securial_attribute_defaults
      first_defaults[:string] = "ChangedValue"

      second_defaults = generator.securial_attribute_defaults
      expect(second_defaults[:string]).to eq('"MyString"')
    end
  end

  describe "#create_factory_file" do
    it "generates a factory file with the correct path" do
      expected_path = File.join("lib/securial/factories/securial", "users.rb")
      generator.create_factory_file

      expect(generator).to have_received(:template).with("factory.erb", expected_path)
    end

    context "with a different model name" do
      let(:model_name) { "product" }

      it "generates a factory file with the correct pluralized name" do
        expected_path = File.join("lib/securial/factories/securial", "products.rb")
        generator.create_factory_file

        expect(generator).to have_received(:template).with("factory.erb", expected_path)
      end
    end

    context "with non-standard model name" do
      let(:model_name) { "person" }

      it "correctly pluralizes irregular nouns" do
        expected_path = File.join("lib/securial/factories/securial", "people.rb")
        generator.create_factory_file

        expect(generator).to have_received(:template).with("factory.erb", expected_path)
      end
    end
  end

  describe "generator arguments" do
    let(:attributes) { ["name:string", "age:integer", "active:boolean"] }

    it "stores the passed attributes" do
      expect(generator.attributes.map(&:name)).to eq(["name", "age", "active"])
      expect(generator.attributes.map(&:type)).to eq([:string, :integer, :boolean])
    end
  end
end
