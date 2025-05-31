require "spec_helper"

RSpec.describe Securial::Logger do
  let(:log_file_path) { Rails.root.join("log", "securial_test.log") }
  let(:file_content) { File.exist?(log_file_path) ? File.read(log_file_path) : "" }

  before do
    File.delete(log_file_path) if File.exist?(log_file_path)
    Securial.instance_variable_set(:@logger, nil)

    # Patch Rails.root.join to give us the test log file when called from Securial::Logger
    allow(Rails.root).to receive(:join).and_wrap_original do |m, *args|
      if args == ["log", "securial.log"]
        log_file_path
      else
        m.call(*args)
      end
    end
  end

  after do
    File.delete(log_file_path) if File.exist?(log_file_path)
    Securial.instance_variable_set(:@logger, nil)
  end

  def with_config(file: true, stdout: true, file_level: :info, stdout_level: :info, stdout_io: nil)
    allow(Securial.configuration).to receive_messages(log_to_file: file, log_to_stdout: stdout, log_file_level: file_level, log_stdout_level: stdout_level)
    yield(stdout_io)
  end

  it "logs to both file and stdout with correct levels" do
    stdout_io = StringIO.new
    with_config(file: true, stdout: true, file_level: :warn, stdout_level: :debug, stdout_io: stdout_io) do |stdout|
      # Patch Logger.new(STDOUT) to use our StringIO instead
      allow(::Logger).to receive(:new).and_wrap_original do |orig, output, *args|
        if output == STDOUT
          orig.call(stdout_io, *args)
        else
          orig.call(output, *args)
        end
      end

      logger = described_class.build

      logger.debug("debug message")
      logger.info("info message")
      logger.warn("warn message")
      logger.error("error message")

      logger.warn("warn to file")
      logger.error("error to file")

      # Flush file logger to ensure content is written
      targets = logger.instance_variable_get(:@logger)&.instance_variable_get(:@targets) ||
                logger.instance_variable_get(:@targets)
      targets&.each { |l| l.flush if l.respond_to?(:flush) }

      expect(stdout_io.string).to match(/debug message.*info message.*warn message.*error message/m)
      expect(file_content).to include("warn to file")
      expect(file_content).to include("error to file")
      expect(file_content).not_to include("debug message")
      expect(file_content).not_to include("info message")
    end
  end

  it "does not log to file if file output is disabled" do
    stdout_io = StringIO.new
    with_config(file: false, stdout: true, stdout_io: stdout_io) do |stdout|
      allow(::Logger).to receive(:new).and_wrap_original do |orig, output, *args|
        if output == STDOUT
          orig.call(stdout_io, *args)
        else
          orig.call(output, *args)
        end
      end

      logger = described_class.build
      logger.info("should only go to stdout")
      targets = logger.instance_variable_get(:@logger)&.instance_variable_get(:@targets) ||
                logger.instance_variable_get(:@targets)
      targets&.each { |l| l.flush if l.respond_to?(:flush) }
      expect(File).not_to exist(log_file_path)
    end
  end

  it "does not log to stdout if stdout is disabled" do
    with_config(file: true, stdout: false) do |_|
      logger = described_class.build
      logger.info("should only go to file")
      targets = logger.instance_variable_get(:@logger)&.instance_variable_get(:@targets) ||
                logger.instance_variable_get(:@targets)
      targets&.each { |l| l.flush if l.respond_to?(:flush) }
      expect(file_content).to include("should only go to file")
    end
  end

  it "respects per-output log levels" do
    stdout_io = StringIO.new
    with_config(file: true, stdout: true, file_level: :error, stdout_level: :debug, stdout_io: stdout_io) do |stdout|
      allow(::Logger).to receive(:new).and_wrap_original do |orig, output, *args|
        if output == STDOUT
          orig.call(stdout_io, *args)
        else
          orig.call(output, *args)
        end
      end

      logger = described_class.build
      logger.debug("debug only to stdout")
      logger.info("info only to stdout")
      logger.error("error to both")
      targets = logger.instance_variable_get(:@logger)&.instance_variable_get(:@targets) ||
                logger.instance_variable_get(:@targets)
      targets&.each { |l| l.flush if l.respond_to?(:flush) }
      expect(stdout_io.string).to match(/debug only to stdout.*info only to stdout.*error to both/m)
      expect(file_content).to include("error to both")
      expect(file_content).not_to include("debug only to stdout")
      expect(file_content).not_to include("info only to stdout")
    end
  end

  it "outputs color codes to stdout in development (not in test)" do
    stdout_io = StringIO.new
    with_config(file: false, stdout: true, stdout_level: :info, stdout_io: stdout_io) do |stdout|
      allow(::Logger).to receive(:new).and_wrap_original do |orig, output, *args|
        if output == STDOUT
          orig.call(stdout_io, *args)
        else
          orig.call(output, *args)
        end
      end

      # Simulate Rails.env.development? for this test
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))

      logger = described_class.build
      logger.info("color test")
      expect(stdout_io.string).to include("\e[32m")
      expect(stdout_io.string).to include("color test")
      expect(stdout_io.string).to include("\e[0m")
    end
  end

  it "outputs plain format to file" do
    with_config(file: true, stdout: false, file_level: :info) do |_|
      logger = described_class.build
      logger.info("plain file format")
      targets = logger.instance_variable_get(:@logger)&.instance_variable_get(:@targets) ||
                logger.instance_variable_get(:@targets)
      targets&.each { |l| l.flush if l.respond_to?(:flush) }
      expect(file_content).to include("plain file format")
      expect(file_content).not_to match(/\e\[\d+m/)
    end
  end

  it "handles TaggedLogging tags" do
    with_config(file: true, stdout: false) do |_|
      logger = described_class.build
      logger.tagged("TAG1", "TAG2") { logger.info("tagged message") }
      targets = logger.instance_variable_get(:@logger)&.instance_variable_get(:@targets) ||
                logger.instance_variable_get(:@targets)
      targets&.each { |l| l.flush if l.respond_to?(:flush) }
      expect(file_content).to include("[TAG1] [TAG2] tagged message")
    end
  end

  it "logs nothing if both outputs are disabled" do
    with_config(file: false, stdout: false) do |_|
      logger = described_class.build
      logger.info("should not log")
      expect(File).not_to exist(log_file_path)
    end
  end
end
