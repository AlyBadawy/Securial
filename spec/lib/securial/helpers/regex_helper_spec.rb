require 'rails_helper'

module Securial
  RSpec.describe Helpers::RegexHelper do
    describe 'EMAIL_REGEX' do
      it 'matches valid email addresses' do
        valid_emails = [
          'user@example.com',
          'user.name@example.com',
          'user+label@example.com',
          'user@sub.example.com',
        ]

        expect(valid_emails).to all(match(described_class::EMAIL_REGEX))
      end

      it 'does not match invalid email addresses' do
        invalid_emails = [
          'user@',
          '@example.com',
          'user@.com',
          'user@example.',
          'user name@example.com',
          'user@exam ple.com',
        ]

        aggregate_failures do
          invalid_emails.each do |username|
            expect(username).not_to match(described_class::EMAIL_REGEX)
          end
        end
      end
    end

    describe 'USERNAME_REGEX' do
      it 'matches valid usernames' do
        valid_usernames = [
          'john_doe',
          'jane.doe',
          'user123',
          'a_b_c',
          'example',
        ]

        expect(valid_usernames).to all(match(described_class::USERNAME_REGEX))
      end

      it 'does not match invalid usernames' do
        invalid_usernames = [
          '123user',           # starts with number
          'user__name',        # consecutive underscores
          'user..name',        # consecutive dots
          'user_',             # ends with underscore
          'user.',             # ends with dot
          'user name',         # contains space
          'user@name',         # contains special character
        ]

        aggregate_failures do
          invalid_usernames.each do |username|
            expect(username).not_to match(described_class::USERNAME_REGEX)
          end
        end
      end
    end

    describe '#valid_email?' do
      it 'returns true for valid email addresses' do
        expect(described_class.valid_email?('user@example.com')).to be true
      end

      it 'returns false for invalid email addresses' do
        expect(described_class.valid_email?('invalid-email')).to be false
      end
    end

    describe '#valid_username?' do
      it 'returns true for valid usernames' do
        expect(described_class.valid_username?('john_doe')).to be true
      end

      it 'returns false for invalid usernames' do
        expect(described_class.valid_username?('123user')).to be false
      end
    end
  end
end
