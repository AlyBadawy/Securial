require "rails_helper"

RSpec.describe Securial::Config::Signature do
  describe ".config_signature" do
    subject(:config_signature) { described_class.config_signature }

    it "returns a Hash" do
      expect(config_signature).to be_a(Hash)
    end

    it "includes all expected keys" do
      expected_keys = [
        :app_name,
        :log_to_file, :log_file_level, :log_to_stdout, :log_stdout_level,
        :admin_role,
        :session_expiration_duration, :session_secret, :session_algorithm, :session_refresh_token_expires_in,
        :mailer_sender, :mailer_sign_up_enabled, :mailer_sign_up_subject, :mailer_sign_in_enabled,
        :mailer_sign_in_subject, :mailer_update_account_enabled, :mailer_update_account_subject,
        :mailer_forgot_password_subject,
        :password_min_length, :password_max_length, :password_complexity, :password_expires,
        :password_expires_in, :reset_password_token_expires_in, :reset_password_token_secret,
        :response_keys_format, :timestamps_in_response,
        :security_headers, :rate_limiting_enabled, :rate_limit_requests_per_minute,
        :rate_limit_response_status, :rate_limit_response_message
      ]
      expect(config_signature.keys).to include(*expected_keys)
    end

    it "has each key with a hash containing at least :type and :default" do
      config_signature.each do |_key, opts|
        expect(opts).to be_a(Hash)
        expect(opts).to include(:type)
        expect(opts).to include(:default)
      end
    end
  end

  describe ".default_config_attributes" do
    subject(:defaults) { described_class.default_config_attributes }

    it "returns a Hash" do
      expect(defaults).to be_a(Hash)
    end

    it "has same keys as config_signature" do
      expect(defaults.keys).to match_array(described_class.config_signature.keys)
    end

    it "maps each key to its default value" do
      described_class.config_signature.each do |key, opts|
        expect(defaults[key]).to eq(opts[:default])
      end
    end
  end

  describe "each signature section" do
    it "returns a hash for general_signature" do
      expect(described_class.send(:general_signature)).to be_a(Hash)
    end

    it "returns a hash for logger_signature" do
      expect(described_class.send(:logger_signature)).to be_a(Hash)
    end

    it "returns a hash for roles_signature" do
      expect(described_class.send(:roles_signature)).to be_a(Hash)
    end

    it "returns a hash for session_signature" do
      expect(described_class.send(:session_signature)).to be_a(Hash)
    end

    it "returns a hash for mailer_signature" do
      expect(described_class.send(:mailer_signature)).to be_a(Hash)
    end

    it "returns a hash for password_signature" do
      expect(described_class.send(:password_signature)).to be_a(Hash)
    end

    it "returns a hash for response_signature" do
      expect(described_class.send(:response_signature)).to be_a(Hash)
    end

    it "returns a hash for security_signature" do
      expect(described_class.send(:security_signature)).to be_a(Hash)
    end
  end

  describe "logging signature" do
    context "when in test environment" do
      before do
        allow(Rails.env).to receive(:test?).and_return(true)
      end

      it "has log_to_file set to false" do
        expect(described_class.config_signature[:log_to_file][:default]).to be false
      end

      it "has log_to_stdout set to false" do
        expect(described_class.config_signature[:log_to_stdout][:default]).to be false
      end
    end

    context "when not in test environment" do
      before do
        allow(Rails.env).to receive(:test?).and_return(false)
      end

      it "has log_to_file set to true" do
        expect(described_class.config_signature[:log_to_file][:default]).to be true
      end

      it "has log_to_stdout set to true" do
        expect(described_class.config_signature[:log_to_stdout][:default]).to be true
      end
    end
  end
end
