require "spec_helper"

describe "securial_new and helpers" do
  before do
    load File.expand_path("../../../../../lib/securial/cli/securial_new.rb", __FILE__)
  end

  let(:app_name) { "my_app" }
  let(:rails_options) { ["--api"] }

  describe "#securial_new" do
    it "calls all steps in order" do # rubocop:disable RSpec/MultipleExpectations
      allow(self).to receive(:create_rails_app)
      allow(self).to receive(:add_securial_gem)
      allow(self).to receive(:install_gems)
      allow(self).to receive(:install_securial)
      allow(self).to receive(:mount_securial_engine)
      allow(self).to receive(:print_final_instructions)
      allow(self).to receive(:puts)

      securial_new(app_name, rails_options)

      expect(self).to have_received(:create_rails_app).with(app_name, rails_options).ordered
      expect(self).to have_received(:add_securial_gem).with(app_name).ordered
      expect(self).to have_received(:install_gems).with(app_name).ordered
      expect(self).to have_received(:install_securial).with(app_name).ordered
      expect(self).to have_received(:mount_securial_engine).with(app_name).ordered
      expect(self).to have_received(:print_final_instructions).with(app_name).ordered
    end

    it "prints creation message" do
      allow(self).to receive(:create_rails_app)
      allow(self).to receive(:add_securial_gem)
      allow(self).to receive(:install_gems)
      allow(self).to receive(:install_securial)
      allow(self).to receive(:mount_securial_engine)
      allow(self).to receive(:print_final_instructions)
      expect { securial_new(app_name, rails_options) }
        .to output(/🏗️  Creating new Rails app: #{app_name}/).to_stdout
    end
  end

  describe "#create_rails_app" do
    it "runs rails new with given options" do
      allow(self).to receive(:run)
      create_rails_app("my_app", ["--api"])
      expect(self).to have_received(:run).with("rails new my_app --api")
    end
  end

  describe "#add_securial_gem" do
    it "prints and appends securial to Gemfile" do
      gemfile_path = File.join(app_name, "Gemfile")
      file_double = instance_double(File)
      allow(self).to receive(:puts)
      allow(File).to receive(:join).and_call_original
      allow(File).to receive(:open).with(gemfile_path, "a").and_yield(file_double)
      allow(file_double).to receive(:puts)

      add_securial_gem(app_name)

      expect(self).to have_received(:puts).with("📦  Adding Securial gem to Gemfile")
      expect(file_double).to have_received(:puts).with("\ngem 'securial'")
    end
  end

  describe "#install_gems" do
    it "runs bundle install in app dir" do
      allow(self).to receive(:run)
      install_gems(app_name)
      expect(self).to have_received(:run).with("bundle install", chdir: app_name)
    end
  end

  describe "#install_securial" do
    it "prints and runs generator and migration" do
      allow(self).to receive(:puts)
      allow(self).to receive(:run)
      install_securial(app_name)
      expect(self).to have_received(:puts).with("🔧  Installing Securial")
      expect(self).to have_received(:run).with("bin/rails generate securial:install", chdir: app_name)
      expect(self).to have_received(:run).with("bin/rails db:migrate", chdir: app_name)
    end
  end

  describe "#mount_securial_engine" do
    it "prints and mounts the engine in routes.rb" do
      routes_path = File.join(app_name, "config/routes.rb")
      original_routes = "Rails.application.routes.draw do\n"
      updated_routes = "Rails.application.routes.draw do\n  mount Securial::Engine => '/securial'\n"

      allow(self).to receive(:puts)
      allow(File).to receive(:join).and_call_original
      allow(File).to receive(:read).with(routes_path).and_return(original_routes)
      allow(File).to receive(:write)

      mount_securial_engine(app_name)

      expect(self).to have_received(:puts).with("🔗  Mounting Securial engine in routes")
      expect(File).to have_received(:write).with(routes_path, updated_routes)
    end
  end

  describe "#print_final_instructions" do
    it "prints installation instructions" do
      expect { print_final_instructions(app_name) }
        .to output(/Securial has been successfully installed.+cd #{app_name}.+rails server/m).to_stdout
    end
  end
end
