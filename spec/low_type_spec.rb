# frozen_string_literal: true

require_relative 'fixtures/low_hello.rb'

RSpec.describe LowHello do
  subject(:hello) { described_class.new(greeting, name:) }

  let(:greeting) { 'Hey' }
  let(:name) { 'Mate' }

  describe '#initialize' do
    it 'instantiates a typed class' do
      expect { hello }.not_to raise_error
    end

    context 'when the arg type is incorrect' do
      let(:greeting) { 123 }

      it 'raises an invalid type error' do
        expect { hello }.to raise_error(LowType::InvalidTypeError)
      end
    end
  end

  describe '#with_required_type' do
    it 'passes through the argument' do
      expect(hello.with_required_type('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'raises a required type error' do
        expect { hello.with_required_type }.to raise_error(LowType::RequiredTypeError)
      end
    end
  end

  describe '#with_default_type' do
    it 'passes through the argument' do
      expect(hello.with_default_type('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(hello.with_default_type).to eq('Hello')
      end
    end
  end
end
