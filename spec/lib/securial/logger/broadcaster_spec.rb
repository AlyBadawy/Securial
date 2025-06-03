require "rails_helper"

RSpec.describe Securial::Logger::Broadcaster do
  let(:fake_logger_one) { instance_double(Logger, info: nil) }
  let(:fake_logger_two) { instance_double(Logger, info: nil) }
  let(:broadcaster)  { described_class.new([fake_logger_one, fake_logger_two]) }

  it "forwards log calls to all loggers" do
    allow(fake_logger_one).to receive(:info)
    allow(fake_logger_two).to receive(:info)

    broadcaster.info("msg")

    expect(fake_logger_one).to have_received(:info).with("msg")
    expect(fake_logger_two).to have_received(:info).with("msg")
  end

  it "closes all loggers when close is called" do
    allow(fake_logger_one).to receive(:close)
    allow(fake_logger_two).to receive(:close)

    broadcaster.close

    expect(fake_logger_one).to have_received(:close)
    expect(fake_logger_two).to have_received(:close)
  end

  it "returns nil for the formatter" do
    expect(broadcaster.formatter).to be_nil
  end

  describe "#<<" do
    it "forwards the message to all loggers" do
      allow(fake_logger_one).to receive(:<<)
      allow(fake_logger_two).to receive(:<<)

      broadcaster << "test message"

      expect(fake_logger_one).to have_received(:<<).with("test message")
      expect(fake_logger_two).to have_received(:<<).with("test message")
    end
  end

  describe "monkey-patching Logger methods" do
    let(:logger_primary) { double("Logger", foo: "foo1", bar: "bar1") } # rubocop:disable RSpec/VerifiedDoubles
    let(:logger_secondary) { double("Logger", foo: "foo2", bar: "bar2") } # rubocop:disable RSpec/VerifiedDoubles
    let(:broadcaster) { described_class.new([logger_primary, logger_secondary]) }

    describe "#respond_to_missing?" do
      it "returns true if any logger responds to the method" do
        allow(logger_primary).to receive(:respond_to?).with(:foo, false).and_return(true)
        allow(logger_secondary).to receive(:respond_to?).with(:foo, false).and_return(false)
        expect(broadcaster.respond_to?(:foo)).to be true
      end

      it "returns false if no logger responds to the method" do
        allow(logger_primary).to receive(:respond_to?).with(:baz, false).and_return(false)
        allow(logger_secondary).to receive(:respond_to?).with(:baz, false).and_return(false)
        expect(broadcaster.respond_to?(:baz)).to be false
      end
    end

    describe "#method_missing" do
      context "when all loggers respond to the method" do
        it "calls the method on all loggers and returns their results" do
          allow(logger_primary).to receive(:foo).with("bar").and_return("foo1")
          allow(logger_secondary).to receive(:foo).with("bar").and_return("foo2")

          result = broadcaster.foo("bar")

          expect(logger_primary).to have_received(:foo).with("bar")
          expect(logger_secondary).to have_received(:foo).with("bar")
          expect(result).to eq(["foo1", "foo2"])
        end

        it "forwards blocks to the loggers" do
          allow(logger_primary).to receive(:bar).with(no_args).and_yield.and_return("block1")
          allow(logger_secondary).to receive(:bar).with(no_args).and_yield.and_return("block2")
          results = []
          broadcaster.bar { results << :block_ran }
          expect(logger_primary).to have_received(:bar).with(no_args)
          expect(logger_secondary).to have_received(:bar).with(no_args)
          expect(results).to eq([:block_ran, :block_ran])
        end
      end


      context "when not all loggers respond to the method" do
        it "raises NoMethodError" do
          allow(logger_primary).to receive(:respond_to?).with(:baz).and_return(true)
          allow(logger_secondary).to receive(:respond_to?).with(:baz).and_return(false)
          expect { broadcaster.baz }.to raise_error(NoMethodError)
        end
      end
    end
  end

  context "when loggers support tagged" do
    let(:tagged_logger_one) { instance_double(ActiveSupport::TaggedLogging) }
    let(:tagged_logger_two) { instance_double(ActiveSupport::TaggedLogging) }
    let(:broadcaster)       { described_class.new([tagged_logger_one, tagged_logger_two]) }

    it "calls tagged on all loggers that respond to tagged" do
      allow(tagged_logger_one).to receive(:tagged).and_yield
      allow(tagged_logger_two).to receive(:tagged).and_yield

      broadcaster.tagged("foo") { }

      expect(tagged_logger_one).to have_received(:tagged).with("foo")
      expect(tagged_logger_two).to have_received(:tagged).with("foo")
    end

    it "does not raise an error if a logger does not support tagged" do
      allow(tagged_logger_two).to receive(:tagged).and_yield

      expect {
        broadcaster.tagged("foo") { }
      }.not_to raise_error

      expect(tagged_logger_two).to have_received(:tagged).with("foo")
    end

    it "doesn't raise an error if no loggers support tagged" do
      broadcaster = described_class.new([])

      expect {
        broadcaster.tagged("foo") { }
      }.not_to raise_error
    end
  end
end
