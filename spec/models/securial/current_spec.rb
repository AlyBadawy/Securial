require 'rails_helper'

RSpec.describe Securial::Current, type: :model do
  # Reset Current between tests to avoid test pollution
  after { described_class.reset }

  describe 'attributes' do
    it 'defines session attribute' do
      expect(described_class).to respond_to(:session)
      expect(described_class).to respond_to(:session=)
    end
  end

  describe '#user delegation' do
    it 'delegates user to session' do
      session = instance_double(Securial::Session, user: 'test_user')
      described_class.session = session

      expect(described_class.user).to eq('test_user')
      expect(session).to have_received(:user)
    end

    it 'returns nil when session is nil' do
      described_class.session = nil
      expect(described_class.user).to be_nil
    end
  end

  describe 'thread isolation' do
    it 'maintains separate values between threads' do
      # Set value in main thread
      session1 = instance_double(Securial::Session, user: 'user1')
      described_class.session = session1

      # Verify isolation in separate thread
      thread_value = Thread.new do
        session2 = instance_double(Securial::Session, user: 'user2')
        described_class.session = session2
        described_class.session
      end.value

      expect(described_class.session).to eq(session1)
      expect(thread_value).not_to eq(session1)
    end
  end

  describe '.reset' do
    it 'clears all attributes' do
      session = instance_double(Securial::Session, user: 'test_user')
      described_class.session = session

      described_class.reset

      expect(described_class.session).to be_nil
    end
  end
end
