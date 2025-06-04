require 'rails_helper'

RSpec.describe Securial::Config::Configuration do
  before do
    # Simulate a non-test Rails environment for default values
    allow(Rails.env).to receive(:test?).and_return(false)
  end

  describe '.default_config_attributes' do
    it 'returns a hash of attribute defaults' do
      expect(described_class.default_config_attributes).to include({
        log_to_file: true,
        log_to_stdout: true,
      })
    end
  end

  describe '#initialize' do
    it 'sets instance variables to the defaults from default_config_attributes' do
      config = described_class.new
      expect(config.log_to_file).to be(true)
      expect(config.log_to_stdout).to be(true)
    end
  end

  describe 'attribute accessors' do
    let(:config) { described_class.new }

    it 'returns the current value via getter' do
      expect(config.log_to_file).to be(true)
      expect(config.log_to_stdout).to be(true)
    end

    it 'sets the value via setter and updates the instance variable' do
      config.log_to_file = false
      config.log_to_stdout = false
      expect(config.log_to_file).to be(false)
      expect(config.log_to_stdout).to be(false)
    end

    it 'calls validate! each time a setter is used' do
      allow(config).to receive(:validate!).and_call_original
      config.log_to_file = false
      expect(config).to have_received(:validate!)
      config.log_to_stdout = false
      expect(config).to have_received(:validate!).twice
    end
  end

  describe 'private #validate!' do
    it 'is a private method' do
      expect(described_class.private_instance_methods).to include(:validate!)
    end
  end
end
