require "rails_helper"

RSpec.describe Securial::VersionChecker do
  let(:logger) { instance_spy(Logger) }

  before do
    allow(Securial).to receive(:logger).and_return(logger)
    stub_const("Securial::VERSION", "1.0.0")
  end

  context "when a newer version is available" do
    let(:http_response) { instance_double(Net::HTTPResponse, body: '{"version":"2.0.0"}') }
    let(:http) { instance_double(Net::HTTP, request: http_response) }

    before do
      allow(Net::HTTP).to receive(:start).and_return(http)
      allow(JSON).to receive(:parse).and_return({ "version" => "2.0.0" })
    end

    it "logs an update message and update instructions" do
      described_class.check_latest_version
      expect(logger).to have_received(:info).with("A newer version (2.0.0) of Securial is available. You are using 1.0.0.").ordered
      expect(logger).to have_received(:info).with("Please consider updating!").ordered
      expect(logger).to have_received(:debug).with("You can update Securial by running the following command in your terminal:").ordered
      expect(logger).to have_received(:debug).with("`bundle update securial`").ordered
    end
  end

  context "when the current version is the latest" do
    let(:http_response) { instance_double(Net::HTTPResponse, body: '{"version":"1.0.0"}') }
    let(:http) { instance_double(Net::HTTP, request: http_response) }

    before do
      allow(Net::HTTP).to receive(:start).and_return(http)
      allow(JSON).to receive(:parse).and_return({ "version" => "1.0.0" })
    end

    it "logs that the version is up to date and no updates" do
      described_class.check_latest_version
      expect(logger).to have_received(:info).with("You are using the latest version of Securial (1.0.0).").ordered
      expect(logger).to have_received(:debug).with("No updates available at this time.").ordered
    end
  end

  context "when an error occurs" do
    before do
      allow(Net::HTTP).to receive(:start).and_raise(StandardError.new("network fail"))
    end

    it "logs the error as debug" do
      described_class.check_latest_version
      expect(logger).to have_received(:debug).with(/Version check failed: network fail/)
    end
  end
end
