require "rails_helper"

RSpec.describe Securial::Logger::Builder do
  describe ".build" do
    it "returns a Broadcaster with loggers" do
      broadcaster = described_class.build
      expect(broadcaster).to be_a(Securial::Logger::Broadcaster)
      expect(broadcaster).to respond_to(:info)
      expect(broadcaster).to respond_to(:tagged)
    end

    it "creates a file logger if log_to_file is true" do
      allow(Securial.configuration).to receive_messages(log_to_file: true, log_file_level: :debug)

      broadcaster = described_class.build
      expect(broadcaster.loggers.first).to be_a(ActiveSupport::TaggedLogging)
      expect(broadcaster.loggers.first.instance_variable_get(:@logdev).filename.to_s).to include("securial-test.log")
    end

    it "creates a stdout logger if log_to_stdout is true" do
      allow(Securial.configuration).to receive_messages(log_to_stdout: true, log_stdout_level: :debug)

      broadcaster = described_class.build
      expect(broadcaster.loggers.last).to be_a(ActiveSupport::TaggedLogging)
      expect(broadcaster.loggers.last.instance_variable_get(:@logdev).dev).to eq($stdout)
    end

    it "does not create a file logger if log_to_file is false" do
      allow(Securial.configuration).to receive_messages(log_to_file: false)

      broadcaster = described_class.build
      expect(broadcaster.loggers).not_to include(an_instance_of(ActiveSupport::TaggedLogging))
    end

    it "does not create a stdout logger if log_to_stdout is false" do
      allow(Securial.configuration).to receive_messages(log_to_stdout: false)

      broadcaster = described_class.build
      expect(broadcaster.loggers).not_to include(an_instance_of(ActiveSupport::TaggedLogging))
    end

    it "sets the correct log levels for file and stdout loggers" do
      allow(Securial.configuration).to receive_messages(log_to_file: true, log_file_level: :info,
                                                        log_to_stdout: true, log_stdout_level: :warn)

      broadcaster = described_class.build
      expect(broadcaster.loggers.first.level).to eq(::Logger::INFO)
      expect(broadcaster.loggers.last.level).to eq(::Logger::WARN)
    end

    it "sets the progname for the loggers" do
      allow(Securial.configuration).to receive_messages(log_to_file: true, log_to_stdout: true)

      broadcaster = described_class.build
      expect(broadcaster.loggers.first.progname).to eq("Securial")
      expect(broadcaster.loggers.last.progname).to eq("Securial")
    end

    it "uses the correct formatters for file and stdout loggers" do
      allow(Securial.configuration).to receive_messages(log_to_file: true, log_to_stdout: true)

      broadcaster = described_class.build
      expect(broadcaster.loggers.first.formatter).to be_a(Securial::Logger::Formatter::PlainFormatter)
      expect(broadcaster.loggers.last.formatter).to be_a(Securial::Logger::Formatter::ColorfulFormatter)
    end

    it "returns an empty broadcaster if no loggers are configured" do
      allow(Securial.configuration).to receive_messages(log_to_file: false, log_to_stdout: false)

      broadcaster = described_class.build
      expect(broadcaster.loggers).to be_empty
    end

    it "returns a broadcaster with multiple loggers if both file and stdout logging are enabled" do
      allow(Securial.configuration).to receive_messages(log_to_file: true, log_to_stdout: true)

      broadcaster = described_class.build
      expect(broadcaster.loggers.size).to eq(2)
      expect(broadcaster.loggers.first).to be_a(ActiveSupport::TaggedLogging)
      expect(broadcaster.loggers.last).to be_a(ActiveSupport::TaggedLogging)
    end
  end
end
