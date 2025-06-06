require "rails_helper"

RSpec.describe Securial do
  describe "VERSION" do
    subject(:version) { Securial::VERSION }

    it "has a version number" do
      expect(version).not_to be_nil
    end

    it "follows semantic versioning format" do
      expect(version).to match(/^\d+\.\d+\.\d+$/)
    end

    it "is the correct version" do
      expect(version).to eq("0.8.1")
    end

    it "has three version segments" do
      major, minor, patch = version.split(".")
      expect(major).to match(/^\d+$/)
      expect(minor).to match(/^\d+$/)
      expect(patch).to match(/^\d+$/)
    end

    it "can be compared with other versions" do
      expect(Gem::Version.new(version)).to be_a(Gem::Version)
    end

    it "is included in the gem specification" do
      expect(Gem.loaded_specs["securial"].version.to_s).to eq(version)
    end
  end
end
