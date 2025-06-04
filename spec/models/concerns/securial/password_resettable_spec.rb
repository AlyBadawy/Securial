require "rails_helper"

RSpec.describe Securial::PasswordResettable, type: :model do
  let(:user) { test_class.create!(email_address: "test@example.com", password: "Passw0rd!", password_confirmation: "Passw0rd!") }
  let(:test_class) do
    Class.new(ApplicationRecord) do
      def self.name; "TestUser"; end
      self.table_name = "test_users"
      include Securial::PasswordResettable
    end
  end

  before do
    allow(Securial.configuration).to receive(:reset_password_token_expires_in).and_return(2.hours)
  end

  describe "#generate_reset_password_token!" do
    it "sets a secure token and timestamp" do
      freeze_time do
        user.generate_reset_password_token!
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_token_created_at).to eq(Time.current)
      end
    end
  end

  describe "#reset_password_token_valid?" do
    context "when token is missing" do
      it "returns false" do
        expect(user.reset_password_token_valid?).to be false
      end
    end

    context "when duration is not a valid duration" do
      it "returns false" do
        user.update!(
          reset_password_token: "abc123",
          reset_password_token_created_at: Time.current
        )
        allow(Securial.configuration).to receive(:reset_password_token_expires_in).and_return("2hours") # invalid
        expect(user.reset_password_token_valid?).to be false
      end
    end

    context "when token is expired" do
      it "returns false" do
        user.update!(
          reset_password_token: "abc123",
          reset_password_token_created_at: 3.hours.ago
        )
        expect(user.reset_password_token_valid?).to be false
      end
    end

    context "when token is still valid" do
      it "returns true" do
        user.update!(
          reset_password_token: "abc123",
          reset_password_token_created_at: 1.hour.ago
        )
        expect(user.reset_password_token_valid?).to be true
      end
    end
  end

  describe "#clear_reset_password_token!" do
    it "clears the token and timestamp" do
      user.update!(
        reset_password_token: "abc123",
        reset_password_token_created_at: Time.current
      )
      user.clear_reset_password_token!
      user.reload
      expect(user.reset_password_token).to be_nil
      expect(user.reset_password_token_created_at).to be_nil
    end
  end

  describe "#password_expired?" do
    context "when password expiration is disabled" do
      before do
        allow(Securial.configuration).to receive(:password_expires).and_return(false)
      end

      it "returns false" do
        expect(user.password_expired?).to be false
      end
    end

    context "when password expiration is enabled" do
      before do
        allow(Securial.configuration).to receive(:password_expires_in).and_return(90.days)
      end

      it "returns true if password was set more than 90 days ago" do
        user.update!(password_changed_at: 91.days.ago)
        expect(user.password_expired?).to be true
      end

      it "returns false if password was set within the last 90 days" do
        user.update!(password_changed_at: 30.days.ago)
        expect(user.password_expired?).to be false
      end

      it "returns true if password_changed_at is nil" do
        user.update!(password_changed_at: nil)
        expect(user.password_expired?).to be true
      end
    end
  end

  describe "password encryption" do
    it "encrypts the password" do
      my_user = test_class.create(email_address: "test@example.com", password: "Password!1", password_confirmation: "Password!1")
      my_user.reload
      expect(my_user.password_digest).not_to eq("Password!1")
    end

    it "does not store the password in plain text" do
      my_user = test_class.create(email_address: "test3@example.com", password: "Password!1", password_confirmation: "Password!1")

      loaded_user = test_class.find(my_user.id)
      expect(loaded_user.password).not_to eq("Password!1")
      expect(loaded_user.password_digest).not_to be_nil
      expect(loaded_user.password_digest).not_to eq("Password!1")
    end
  end

  describe "authentication" do
    it "has secure password" do
      expect(user).to respond_to(:authenticate)
    end

    it "authenticate user by password" do
      expect(test_class.authenticate_by(email_address: user.email_address, password: "invalid_password")).to be_nil
      expect(test_class.authenticate_by(email_address: user.email_address, password: "Passw0rd!")).to eq(user)
    end
  end

  describe "Password Validations" do
    subject { test_class.new }

    it { is_expected.to validate_length_of(:password).is_at_least(Securial.configuration.password_min_length) }
    it { is_expected.to validate_length_of(:password).is_at_most(Securial.configuration.password_max_length) }

    it "requires password confirmation on new records" do
      user = build(:securial_user, password: "Valid1Password!", password_confirmation: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("can't be blank")
    end

    it "requires password confirmation when changing password" do
      user = create(:securial_user)
      user.password = "NewValid1Password!"
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it "doesn't require password confirmation when not changing password" do
      user = create(:securial_user)
      user.first_name = "UpdatedName"
      expect(user).to be_valid
    end

    context "when password complexity is required" do
      it { is_expected.to allow_value("Valid1Password!").for(:password) }
      it { is_expected.not_to allow_value("password").for(:password) }  # no uppercase, digit, or special char
      it { is_expected.not_to allow_value("PASSWORD1").for(:password) } # no lowercase or special char
      it { is_expected.not_to allow_value("Password").for(:password) }  # no digit or special char
      it { is_expected.not_to allow_value("Password1").for(:password) } # no special char
      it { is_expected.not_to allow_value("password!").for(:password) } # no uppercase or digit
      it { is_expected.not_to allow_value("PASSWORD!").for(:password) } # no lowercase or digit
      it { is_expected.not_to allow_value("Pass!").for(:password) }     # no digit and too short
    end
  end
end
