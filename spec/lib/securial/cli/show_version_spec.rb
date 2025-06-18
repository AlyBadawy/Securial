require "spec_helper"

describe "show_version" do
  before do
    load File.expand_path("../../../../../lib/securial/cli/show_version.rb", __FILE__)
  end

  context "when version is available" do
    before do
      allow(self).to receive(:require).with("securial/version")
    end

    it "prints the version" do
      expect { show_version }.to output("Securial v#{Securial::VERSION}\n").to_stdout
    end
  end

  context "when version cannot be loaded" do
    before do
      allow(self).to receive(:require).with("securial/version").and_raise(LoadError)
    end

    it "prints a message if version cannot be loaded" do
      expect { show_version }.to output("Securial version information not available.\n").to_stdout
    end
  end
end
