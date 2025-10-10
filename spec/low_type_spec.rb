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

  describe '#with_type' do
    it 'passes through the argument' do
      expect(hello.with_type('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'raises a required type error' do
        expect { hello.with_type }.to raise_error(LowType::RequiredValueError)
      end
    end
  end

  describe '#with_type_and_default_value' do
    it 'passes through the argument' do
      expect(hello.with_type_and_default_value('Howdy')).to eq('Howdy')
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(hello.with_type_and_default_value).to eq('Hello')
      end
    end
  end

  describe '#with_multiple_types' do
    it 'accepts both arguments types' do
      expect(hello.with_multiple_types('Shalom')).to eq('Shalom')
      expect(hello.with_multiple_types(123)).to eq(123)
    end

    context 'when no arg provided' do
      it 'raises a required type error' do
        expect { hello.with_multiple_types }.to raise_error(LowType::RequiredValueError)
      end
    end
  end

  describe '#with_multiple_types_and_default_value' do
    it 'accepts both arguments types' do
      expect(hello.with_multiple_types_and_default_value('Shalom')).to eq('Shalom')
      expect(hello.with_multiple_types_and_default_value(123)).to eq(123)
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(hello.with_multiple_types_and_default_value).to eq('Salutations')
      end
    end
  end
end
