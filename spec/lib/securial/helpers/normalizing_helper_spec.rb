require 'rails_helper'

module Securial
  RSpec.describe Helpers::NormalizingHelper do
    describe '.normalize_email_address' do
      context 'with valid email addresses' do
        it 'strips whitespace and downcases' do
          expect(described_class.normalize_email_address(' User@Example.COM ')).to eq('user@example.com')
        end

        it 'preserves the email structure while normalizing' do
          expect(described_class.normalize_email_address('First.Last+Tag@Example.COM')).to eq('first.last+tag@example.com')
        end

        it 'handles already normalized emails' do
          expect(described_class.normalize_email_address('user@example.com')).to eq('user@example.com')
        end
      end

      context 'with invalid input' do
        it 'returns an empty string for empty input' do
          expect(described_class.normalize_email_address('')).to eq("")
        end

        it 'handles string with only whitespace' do
          expect(described_class.normalize_email_address('   ')).to eq("")
        end
      end
    end

    describe '.normalize_role_name' do
      context 'with valid role names' do
        it 'strips whitespace and titleizes' do
          expect(described_class.normalize_role_name(' admin user ')).to eq('Admin User')
        end

        it 'handles multiple word roles' do
          expect(described_class.normalize_role_name('super admin user')).to eq('Super Admin User')
        end

        it 'handles already normalized roles' do
          expect(described_class.normalize_role_name('Admin')).to eq('Admin')
        end

        it 'normalizes inconsistent casing' do
          expect(described_class.normalize_role_name('sUpEr AdMiN')).to eq('Super Admin')
        end
      end

      context 'with invalid input' do
        it 'returns empty string for empty string' do
          expect(described_class.normalize_role_name('')).to eq("")
        end

        it 'handles string with only whitespace' do
          expect(described_class.normalize_role_name('   ')).to eq("")
        end
      end
    end
  end
end
