# frozen_string_literal: true

require_relative '../../lib/error_types'
require_relative '../fixtures/low_hello_keywords.rb'

RSpec.describe LowHelloKeywords do
  subject(:hello) { described_class.new(greeting:, name:) }

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
      expect(hello.typed_arg(greeting: 'Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      let(:error_message) { "Invalid argument type 'NilClass' for parameter 'greeting'. Valid types: 'String'" }

      it 'raises a required type error' do
        expect { hello.typed_arg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_arg_and_default_value' do
    it 'passes through the argument' do
      expect(hello.typed_arg_and_default_value(greeting: 'Howdy')).to eq('Howdy')
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(hello.typed_arg_and_default_value).to eq('Hello')
      end
    end
  end

  describe '#multiple_typed_args' do
    it 'accepts both arguments types' do
      expect(hello.multiple_typed_args(greeting: 'Shalom')).to eq('Shalom')
      expect(hello.multiple_typed_args(greeting: 123)).to eq(123)
    end

    context 'when args are wrong types' do
      it 'raises an invalid type error' do
        expect { hello.multiple_typed_args(greeting: true) }.to raise_error(TypeError)
      end
    end

    context 'when no arg is provided' do
      let(:error_message) { "Invalid argument type 'NilClass' for parameter 'greeting'. Valid types: 'String | Integer'" }

      it 'raises a required type error' do
        expect { hello.multiple_typed_args }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#multiple_typed_args_and_default_value' do
    it 'accepts both arguments types' do
      expect(hello.multiple_typed_args_and_default_value(greeting: 'Shalom')).to eq('Shalom')
      expect(hello.multiple_typed_args_and_default_value(greeting: 123)).to eq(123)
    end

    context 'when args are wrong types' do
      it 'raises an invalid type error' do
        expect { hello.multiple_typed_args_and_default_value(greeting: true) }.to raise_error(TypeError)
      end
    end

    context 'when no arg is provided' do
      it 'provides the default value' do
        expect(hello.multiple_typed_args_and_default_value).to eq('Salutations')
      end
    end
  end
end
