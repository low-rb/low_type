# frozen_string_literal: true

require_relative '../lib/error_types'
require_relative 'fixtures/low_instance'

RSpec.describe LowInstance do
  subject { described_class.new }

  describe '#initialize' do
    it 'instantiates a class' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#type_reader' do
    it 'creates a getter' do
      expect(subject.name).to eq('Cher')
    end
  end
end
