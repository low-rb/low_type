# frozen_string_literal: true

require_relative 'fixtures/low_hello.rb'

RSpec.describe LowHello do
  subject(:hello) { described_class.new(greeting, name) }

  let(:greeting) { 'Hey' }
  let(:name) { 'Mate' }

  describe '#initialize' do
    it 'instantiates a typed class' do
      expect { hello }.not_to raise_error
    end

    context 'when the arg type is incorrect' do
      let(:greeting) { 123 }

      it 'raises an invalid type error' do
        expect { hello }.to raise_error(TypeError)
      end
    end
  end

  describe '#typed_arg' do
    it 'passes through the argument' do
      expect(hello.typed_arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'raises a required type error' do
        expect { hello.typed_arg }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#typed_arg_and_default_value' do
    it 'passes through the argument' do
      expect(hello.typed_arg_and_default_value('Howdy')).to eq('Howdy')
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(hello.typed_arg_and_default_value).to eq('Hello')
      end
    end
  end

  describe '#multiple_typed_args' do
    it 'accepts both arguments types' do
      expect(hello.multiple_typed_args('Shalom')).to eq('Shalom')
      expect(hello.multiple_typed_args(123)).to eq(123)
    end

    context 'when args are wrong types' do
      it 'raises an invalid type error' do
        expect { hello.multiple_typed_args(true) }.to raise_error(TypeError)
      end
    end

    context 'when no arg is provided' do
      it 'raises a required type error' do
        expect { hello.multiple_typed_args }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#multiple_typed_args_and_default_value' do
    it 'accepts both arguments types' do
      expect(hello.multiple_typed_args_and_default_value('Shalom')).to eq('Shalom')
      expect(hello.multiple_typed_args_and_default_value(123)).to eq(123)
    end

    context 'when args are wrong types' do
      it 'raises an invalid type error' do
        expect { hello.multiple_typed_args_and_default_value(true) }.to raise_error(TypeError)
      end
    end

    context 'when no arg is provided' do
      it 'provides the default value' do
        expect(hello.multiple_typed_args_and_default_value).to eq('Salutations')
      end
    end
  end

  describe '.class_typed_arg' do
    it 'passes through the argument' do
      expect(described_class.class_typed_arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'raises a required type error' do
        expect { described_class.class_typed_arg }.to raise_error(ArgumentError)
      end
    end
  end
end
