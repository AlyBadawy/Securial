require "rails_helper"

RSpec.describe "Securial Logger" do
  describe ".logger" do
    it "returns a logger instance" do
      expect(Securial.logger).to respond_to(:info)
      expect(Securial.logger).to respond_to(:tagged)
    end

    it "is memoized" do
      logger1 = Securial.logger
      logger2 = Securial.logger
      expect(logger1).to equal(logger2)
    end
  end

  describe ".logger=" do
    it "sets a custom logger" do
      custom_logger = instance_double(Logger)
      Securial.logger = custom_logger
      expect(Securial.logger).to eq(custom_logger)
      # Reset to default for other specs
      Securial.instance_variable_set(:@logger, nil)
    end
  end
end
