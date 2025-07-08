require "spec_helper"
require "securial/cli"

RSpec.describe Securial::CLI do
  let(:cli) { described_class.new }

  before do
    allow(cli).to receive(:create_rails_app)
    allow(cli).to receive(:add_securial_gem)
    allow(cli).to receive(:install_gems)
    allow(cli).to receive(:install_securial)
    allow(cli).to receive(:mount_securial_engine)
    allow(cli).to receive(:print_final_instructions)
    allow(cli).to receive(:show_version)
  end

  describe ".start" do
    it "instantiates and calls start" do
      instance = instance_double(described_class)
      allow(instance).to receive(:start)
      allow(described_class).to receive(:new).and_return(instance)

      described_class.start(["foo"])

      expect(instance).to have_received(:start).with(["foo"])
    end
  end

  describe "#start" do
    it "handles invalid global option" do
      expect {
        cli.start(["-d"])
      }.to raise_error(SystemExit)
        .and output(/ERROR: Illegal option\(s\): -d/).to_stderr
        .and output(/Usage: securial/).to_stdout
    end

    it "shows version and exits" do
      expect {
        cli.start(["--version"])
      }.to raise_error(SystemExit)

      expect(cli).to have_received(:show_version)
    end

    it "shows help and exits" do
      expect {
        cli.start(["--help"])
      }.to raise_error(SystemExit)
        .and output(/Usage: securial/).to_stdout
    end

    it "shows error if command is missing" do
      expect {
        cli.start([])
      }.to raise_error(SystemExit)
        .and output(/Usage: securial/).to_stdout
    end

    it "shows error for unknown command" do
      expect {
        cli.start(["unknown"])
      }.to raise_error(SystemExit)
        .and output(/Usage: securial/).to_stdout
    end

    it "shows error if 'new' command is missing app name" do
      expect {
        cli.start(["new"])
      }.to raise_error(SystemExit)
        .and output(/ERROR: Please provide an app name/).to_stdout
    end

    it "runs securial_new for 'new' command with app name and rails options" do
      allow(cli).to receive(:securial_new)
      expect {
        cli.start(["new", "myapp", "--api", "-T"])
      }.to raise_error(SystemExit)

      expect(cli).to have_received(:securial_new).with("myapp", ["--api", "-T"])
    end
  end

  describe "#handle_flags" do
    it "returns 1 and prints error on illegal option" do
      expect {
        cli.send(:handle_flags, ["-z"])
      }.to output(/ERROR: Illegal option\(s\): -z/).to_stderr
        .and output(/Usage: securial/).to_stdout
    end

    it "returns nil on valid options" do
      expect(cli.send(:handle_flags, ["new", "foo"])).to be_nil
    end
  end

  describe "#handle_commands" do
    before { allow(cli).to receive(:handle_new_command) }

    it "calls handle_new_command for 'new'" do
      cli.send(:handle_commands, ["new", "foo"])
      expect(cli).to have_received(:handle_new_command).with(["foo"])
    end

    it "returns 1 and prints usage for unknown command" do
      expect {
        cli.send(:handle_commands, ["badcmd"])
      }.to output(/Usage: securial/).to_stdout
    end
  end

  describe "#handle_new_command" do
    it "returns 1 with error when app name is missing" do
      expect {
        cli.send(:handle_new_command, [])
      }.to output(/ERROR: Please provide an app name/).to_stdout
    end

    it "calls securial_new when app name is present" do
      allow(cli).to receive(:securial_new)
      expect(cli.send(:handle_new_command, ["foo", "--api"])).to eq(0)
      expect(cli).to have_received(:securial_new).with("foo", ["--api"])
    end
  end

  describe "#show_version" do
    context "when version is available" do
      it "prints the version and exits" do
        allow(cli).to receive(:show_version).and_call_original
        expect {
          cli.send(:show_version)
        }.to output(/Securial v\d+\.\d+\.\d+/).to_stdout
      end
    end

    context "when version is not available" do
      it "prints error message when LoadError occurs" do
        allow(cli).to receive(:show_version).and_call_original

        # Mock the require to raise LoadError
        allow(cli).to receive(:require).with("securial/version").and_raise(LoadError)

        expect {
          cli.send(:show_version)
        }.to output("Securial version information not available.\n").to_stdout
      end
    end
  end

  describe "#securial_new" do
    before do
      allow(cli).to receive(:create_rails_app)
      allow(cli).to receive(:add_securial_gem)
      allow(cli).to receive(:install_gems)
      allow(cli).to receive(:install_securial)
      allow(cli).to receive(:mount_securial_engine)
      allow(cli).to receive(:print_final_instructions)
    end

    it "calls create_rails_app with correct arguments" do
      expect {
        cli.send(:securial_new, "myapp", ["--api", "-T"])
      }.to output(/🏗️  Creating new Rails app: myapp/).to_stdout

      expect(cli).to have_received(:create_rails_app).with("myapp", ["--api", "-T"])
    end

    it "calls all steps in securial_new" do # rubocop:disable RSpec/MultipleExpectations
      expect {
        cli.send(:securial_new, "myapp", ["--api", "-T"])
      }.to output(/🏗️  Creating new Rails app: myapp/).to_stdout

      expect(cli).to have_received(:create_rails_app)
      expect(cli).to have_received(:add_securial_gem)
      expect(cli).to have_received(:install_gems)
      expect(cli).to have_received(:install_securial)
      expect(cli).to have_received(:mount_securial_engine)
      expect(cli).to have_received(:print_final_instructions)
    end
  end

  describe "#create_rails_app" do
    it "creates a new Rails app" do
      allow(cli).to receive(:create_rails_app).and_call_original
      allow(cli).to receive(:run)
      cli.send(:create_rails_app, "myapp", ["--api", "-T"])
      expect(cli).to have_received(:run).with(["rails", "new", "myapp", "--api", "-T"])
    end
  end

  describe "#add_securial_gem" do
    it "adds the Securial gem to the Gemfile" do
      allow(cli).to receive(:add_securial_gem).and_call_original
      FileUtils.mkdir_p("myapp") # Ensure the directory exists
      FileUtils.touch("myapp/Gemfile")
      expect {
        cli.send(:add_securial_gem, "myapp")
      }.to output(/Adding Securial gem to Gemfile/).to_stdout.and change {
        File.read("myapp/Gemfile")
      }.from("").to(include("gem 'securial'"))
      FileUtils.rm("myapp/Gemfile") # Clean up after test
      FileUtils.rmdir("myapp") # Remove the directory
    end
  end

  describe "#install_gems" do
    it "installs the required gems" do
      allow(cli).to receive(:install_gems).and_call_original
      allow(cli).to receive(:run)

      cli.send(:install_gems, "myapp")
      expect(cli).to have_received(:run).with("bundle install", { chdir: "myapp" })
    end
  end

  describe "#install_securial" do
    it "installs the Securial gem" do
      allow(cli).to receive(:install_securial).and_call_original
      allow(cli).to receive(:run)

      expect { cli.send(:install_securial, "myapp") }.to output(/Installing Securial/).to_stdout
      expect(cli).to have_received(:run).with("bin/rails generate securial:install", { chdir: "myapp" })
      expect(cli).to have_received(:run).with("bin/rails db:migrate", { chdir: "myapp" })
    end
  end

  describe "#mount_securial_engine" do
    let(:app_name) { "testapp" }
    let(:routes_path) { File.join(app_name, "config/routes.rb") }
    let(:original_routes) do
      <<~ROUTES
        Rails.application.routes.draw do
          # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
          root "application#index"
        end
      ROUTES
    end
    let(:expected_routes) do
      <<~ROUTES
        Rails.application.routes.draw do
          mount Securial::Engine => '/securial'
          # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
          root "application#index"
        end
      ROUTES
    end

    before do
      # Create the directory structure
      FileUtils.mkdir_p(File.join(app_name, "config"))
      # Create the routes file with initial content
      File.write(routes_path, original_routes)
    end

    after do
      # Clean up test files
      FileUtils.rm_rf(app_name) if Dir.exist?(app_name)
    end

    it "mounts the Securial engine in the application's routes" do
      allow(cli).to receive(:mount_securial_engine).and_call_original
      allow(cli).to receive(:run)

      expect {
        cli.send(:mount_securial_engine, app_name)
      }.to output(/🔗  Mounting Securial engine in routes/).to_stdout

      updated_content = File.read(routes_path)
      expect(updated_content).to eq(expected_routes)
    end
  end

  describe "#print_final_instructions" do
    it "prints final instructions after installation" do
      allow(cli).to receive(:print_final_instructions).and_call_original

      expect {
        cli.send(:print_final_instructions, "myapp")
      }.to output(/Securial has been successfully installed in your Rails app!/).to_stdout
    end
  end

  describe "#run" do
    before do
      allow(cli).to receive(:system)
      allow(cli).to receive(:puts)
      allow(cli).to receive(:abort)
    end

    context "when command succeeds" do
      before do
        allow(cli).to receive(:system).and_return(true)
      end

      it "executes the command and returns 0" do
        result = cli.send(:run, ["echo", "hello"])

        expect(cli).to have_received(:system).with("echo", "hello")
        expect(result).to eq(0)
      end

      it "prints the command being executed" do
        cli.send(:run, ["echo", "hello"])

        expect(cli).to have_received(:puts).with('→ ["echo", "hello"]')
      end

      it "executes string commands" do
        cli.send(:run, "bundle install")

        expect(cli).to have_received(:system).with("bundle install")
      end
    end

    context "when command fails" do
      before do
        allow(cli).to receive(:system).and_return(false)
      end

      it "calls abort with error message" do
        cli.send(:run, ["false"])

        expect(cli).to have_received(:abort).with('❌ Command failed: ["false"]')
      end

      it "prints the command before failing" do
        cli.send(:run, ["false"])

        expect(cli).to have_received(:puts).with('→ ["false"]')
      end
    end

    context "with chdir option" do
      before do
        allow(cli).to receive(:system).and_return(true)
        allow(Dir).to receive(:chdir).and_yield
      end

      it "changes directory before executing command" do
        cli.send(:run, ["ls"], chdir: "myapp")

        expect(Dir).to have_received(:chdir).with("myapp")
        expect(cli).to have_received(:system).with("ls")
      end

      it "executes command in specified directory" do
        result = cli.send(:run, "bundle install", chdir: "myapp")

        expect(Dir).to have_received(:chdir).with("myapp")
        expect(result).to eq(0)
      end

      it "handles command failure in chdir context" do
        allow(cli).to receive(:system).and_return(false)

        cli.send(:run, "false_command", chdir: "myapp")

        expect(cli).to have_received(:abort).with('❌ Command failed: false_command')
      end
    end

    context "with different command formats" do
      before do
        allow(cli).to receive(:system).and_return(true)
      end

      it "handles array commands" do
        cli.send(:run, ["git", "init"])

        expect(cli).to have_received(:system).with("git", "init")
      end

      it "handles string commands" do
        cli.send(:run, "git status")

        expect(cli).to have_received(:system).with("git status")
      end

      it "handles commands with options" do
        cli.send(:run, ["rails", "new", "myapp", "--api"])

        expect(cli).to have_received(:system).with("rails", "new", "myapp", "--api")
      end
    end
  end
end
