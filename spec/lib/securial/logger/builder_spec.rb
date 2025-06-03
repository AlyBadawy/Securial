require "rails_helper"

RSpec.describe Securial::Logger::Builder do
  describe ".build" do
    it "returns a Broadcaster with loggers" do
      broadcaster = described_class.build
      expect(broadcaster).to be_a(Securial::Logger::Broadcaster)
      expect(broadcaster).to respond_to(:info)
      expect(broadcaster).to respond_to(:tagged)
    end
  end
end
