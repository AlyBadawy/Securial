require "spec_helper"

describe "show_help" do
  before do
    load File.expand_path("../../../../../lib/securial/cli/show_help.rb", __FILE__)
  end

  it "prints the help message" do
    expect { show_help }.to output(/Securial CLI/).to_stdout
    expect { show_help }.to output(/Usage:/).to_stdout
    expect { show_help }.to output(/Example:/).to_stdout
    expect { show_help }.to output(/Changelog/).to_stdout
    expect { show_help }.to output(/WIKI/).to_stdout
  end
end
