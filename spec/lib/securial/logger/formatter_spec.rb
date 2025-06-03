require "rails_helper"

RSpec.describe Securial::Logger::Formatter do
  describe Securial::Logger::Formatter::PlainFormatter do
    it "formats logs without color" do
      formatter = described_class.new
      result = formatter.call("INFO", Time.zone.now, "Prog", "hello")
      expect(result).to match(/\[.*\] INFO\s+-- hello/)
    end
  end

  describe Securial::Logger::Formatter::ColorfulFormatter do
    it "formats logs with color codes" do
      formatter = described_class.new
      result = formatter.call("ERROR", Time.zone.now, "Prog", "fail")
      expect(result).to include("\e[31m") # Red for ERROR
      expect(result).to include("fail")
    end
  end
end
