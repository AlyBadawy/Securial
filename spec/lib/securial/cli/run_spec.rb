require "spec_helper"

describe "run" do
  before do
    load File.expand_path("../../../../../lib/securial/cli/run.rb", __FILE__)
  end

  it "executes the command and prints it" do
    allow(self).to receive(:system).with("echo 123").and_return(true)
    expect { run("echo 123") }.to output("→ echo 123\n").to_stdout
  end

  it "aborts if the command fails" do
    allow(self).to receive(:system).with("false_command").and_return(false)
    expect {
      run("false_command")
    }.to raise_error(SystemExit)
      .and output("→ false_command\n").to_stdout
      .and output("❌ Command failed: false_command\n").to_stderr
  end

  it "runs the command in a directory if chdir is given" do
    allow(Dir).to receive(:chdir).with("some_dir").and_yield
    allow(self).to receive(:system).with("echo 123").and_return(true)
    expect { run("echo 123", chdir: "some_dir") }.to output("→ echo 123\n").to_stdout
  end
end
