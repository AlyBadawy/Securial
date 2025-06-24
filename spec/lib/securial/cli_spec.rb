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
    allow(cli).to receive(:run)
    allow(cli).to receive(:securial_new)
  end

  describe ".start" do
    it "instantiates and calls start" do
      instance = double(start: 0) # rubocop:disable RSpec/VerifiedDoubles
      allow(described_class).to receive(:new).and_return(instance)
      described_class.start(["foo"])
      expect(instance).to have_received(:start).with(["foo"])
    end
  end

  describe "#start" do
    it "handles invalid global option" do
      expect { cli.start(["-d"]) }.to output(/ERROR: Illegal option\(s\): -d/).to_stderr.and output(/Usage: securial/).to_stdout.and raise_error(SystemExit)
    end

    it "shows version and exits" do
      allow(cli).to receive(:show_version)
      expect { cli.start(["--version"]) }.to raise_error(SystemExit)
    end

    it "shows help and exits" do
      expect { cli.start(["--help"]) }.to output(/Usage: securial/).to_stdout.and raise_error(SystemExit)
    end

    it "shows error if command is missing" do
      expect { cli.start([]) }.to output(/Usage: securial/).to_stdout.and raise_error(SystemExit)
    end

    it "shows error for unknown command" do
      expect { cli.start(["unknown"]) }.to output(/Usage: securial/).to_stdout.and raise_error(SystemExit)
    end

    it "shows error if 'new' command is missing app name" do
      expect { cli.start(["new"]) }.to output(/ERROR: Please provide an app name/).to_stdout.and raise_error(SystemExit)
    end

    it "runs securial_new for 'new' command with app name and rails options" do
      expect { cli.start(["new", "myapp", "--api", "-T"]) }.to raise_error(SystemExit)
      expect(cli).to have_received(:securial_new).with("myapp", ["--api", "-T"])
    end
  end

  describe "#handle_flags" do
    it "returns 1 and prints error on illegal option" do
      expect { cli.send(:handle_flags, ["-z"]) }.to output(/ERROR: Illegal option\(s\): -z/).to_stderr.and output(/Usage: securial/).to_stdout
    end

    it "returns nil on valid options" do
      expect(cli.send(:handle_flags, ["new", "foo"])).to be_nil
    end
  end

  describe "#handle_commands" do
    before do
      # Add the spy here, in the specific context where it's needed
      allow(cli).to receive(:handle_new_command)
    end

    it "calls handle_new_command for 'new'" do
      cli.send(:handle_commands, ["new", "foo"])
      expect(cli).to have_received(:handle_new_command).with(["foo"])
    end

    it "returns 1 and prints usage for unknown command" do
      expect { cli.send(:handle_commands, ["badcmd"]) }.to output(/Usage: securial/).to_stdout
    end
  end

  describe "#handle_new_command" do
    it "returns 1 with error when app name is missing" do
      expect { cli.send(:handle_new_command, []) }.to output(/ERROR: Please provide an app name/).to_stdout
    end

    it "calls securial_new when app name is present" do
      expect(cli.send(:handle_new_command, ["foo", "--api"])).to eq(0)
      expect(cli).to have_received(:securial_new).with("foo", ["--api"])
    end
  end
end
