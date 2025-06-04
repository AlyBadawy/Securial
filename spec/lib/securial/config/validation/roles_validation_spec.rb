require "rails_helper"


RSpec.describe Securial::Config::Validation::RolesValidation do
  describe ".validate!" do
    let(:config) { instance_double(Securial::Config::Configuration) }

    context "when admin_role is nil" do
      before do
        allow(config).to receive(:admin_role).and_return(nil)
      end

      it "raises RolesValidationError with a descriptive message" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::RolesValidationError,
          "Admin role is not set."
        )
      end
    end

    context "when admin_role is an empty string" do
      before do
        allow(config).to receive(:admin_role).and_return("")
      end

      it "raises RolesValidationError with a descriptive message" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::RolesValidationError,
          "Admin role is not set."
        )
      end
    end

    context "when admin_role is a valid symbol" do
      before do
        allow(config).to receive(:admin_role).and_return(:admin)
      end

      it "does not raise an error" do
        expect { described_class.validate!(config) }.not_to raise_error
      end
    end

    context "when admin_role is a valid string" do
      before do
        allow(config).to receive(:admin_role).and_return("admin")
      end

      it "does not raise an error" do
        expect { described_class.validate!(config) }.not_to raise_error
      end
    end

    context "when admin_role is a pluralized string 'accounts'" do
      before do
        allow(config).to receive(:admin_role).and_return("accounts")
      end

      it "raises RolesValidationError with a descriptive message" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::RolesValidationError,
          "The admin role cannot be 'account' or 'accounts' as it conflicts with the default routes."
        )
      end
    end

    context "when admin_role is an invalid type" do
      before do
        allow(config).to receive(:admin_role).and_return(123)
      end

      it "raises RolesValidationError with a descriptive message" do
        expect { described_class.validate!(config) }.to raise_error(
          Securial::Error::Config::RolesValidationError,
          "Admin role must be a Symbol or String."
        )
      end
    end
  end
end
