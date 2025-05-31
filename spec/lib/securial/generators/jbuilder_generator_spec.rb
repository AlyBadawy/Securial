require "spec_helper"
require "generators/securial/jbuilder/jbuilder_generator"

RSpec.describe Securial::Generators::JbuilderGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __FILE__)

  before(:each) do
    prepare_destination
    allow(Rails.env).to receive(:test?).and_return(true)
  end

  let(:generator) { described_class.new(["test", "name:string", "email:string"]) }

  describe "generator configuration" do
    it "inherits from NamedBase" do
      expect(described_class.superclass).to eq Rails::Generators::NamedBase
    end

    it "has the correct source root" do
      expect(described_class.source_root.to_s).to end_with("templates")
    end
  end

  describe "#create_view_files" do
    before { generator.create_view_files }
    after { FileUtils.rm_rf(Rails.root.join("tmp")) }

    it "creates all view files" do
      expect(Rails.root.to_s + "/tmp").to have_structure {
        directory "app" do
          directory "views" do
            directory "securial" do
              directory "tests" do
                file "_test.json.jbuilder"
                file "index.json.jbuilder"
                file "show.json.jbuilder"
              end
            end
          end
        end
      }
    end
  end

  describe "#attributes_names" do
    it "returns array of attribute names" do
      expect(generator.send(:attributes_names)).to eq(["name", "email"])
    end
  end

  describe "#status_behavior" do
    it "returns :create when behavior is :invoke" do
      allow(generator).to receive(:behavior).and_return(:invoke)
      expect(generator.send(:status_behavior)).to eq(:create)
    end

    it "returns :remove when behavior is :revoke" do
      allow(generator).to receive(:behavior).and_return(:revoke)
      expect(generator.send(:status_behavior)).to eq(:remove)
    end
  end

  describe "#status_color" do
    it "returns :green when behavior is :invoke" do
      allow(generator).to receive(:behavior).and_return(:invoke)
      expect(generator.send(:status_color)).to eq(:green)
    end

    it "returns :red when behavior is :revoke" do
      allow(generator).to receive(:behavior).and_return(:revoke)
      expect(generator.send(:status_color)).to eq(:red)
    end
  end

  describe "status messages" do
    before do
      allow(generator).to receive(:say_status)
      allow(Rails.env).to receive(:test?).and_return(true)
    end

    it "does not call say_status for resource file in test environment" do
      generator.send(:create_resource_file)
      expect(generator).not_to have_received(:say_status)
    end

    it "does not call say_status for index file in test environment" do
      generator.send(:create_index_file)
      expect(generator).not_to have_received(:say_status)
    end

    it "does not call say_status for show file in test environment" do
      generator.send(:create_show_file)
      expect(generator).not_to have_received(:say_status)
    end

    context "when not in test environment" do
      before do
        FileUtils.rm_rf(File.join(generator.destination_root, "app", "views", "securial", "tests"))
        allow(Rails.env).to receive(:test?).and_return(false)
      end

      after do
        FileUtils.rm_rf(File.join(generator.destination_root, "app", "views", "securial", "tests"))
      end

      it "calls say_status for resource file" do
        generator.send(:create_resource_file)
        expect(generator).to have_received(:say_status).with(:create, /.*_test\.json\.jbuilder/, :green)
      end

      it "calls say_status for index file" do
        generator.send(:create_index_file)
        expect(generator).to have_received(:say_status).with(:create, /.*index\.json\.jbuilder/, :green)
      end

      it "calls say_status for show file" do
        generator.send(:create_show_file)
        expect(generator).to have_received(:say_status).with(:create, /.*show\.json\.jbuilder/, :green)
      end
    end
  end
end
