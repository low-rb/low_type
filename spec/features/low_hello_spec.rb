# frozen_string_literal: true

require_relative '../../lib/types/error_types'
require_relative '../fixtures/low_hello'

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
      let(:error_message) { "Invalid argument type 'Integer' for parameter 'greeting'. Valid types: 'String'" }

      it 'raises an invalid type error' do
        expect { hello }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_arg' do
    it 'passes through the argument' do
      expect(hello.typed_arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      let(:error_message) { "Invalid argument type 'NilClass' for parameter 'greeting'. Valid types: 'String'" }

      it 'raises an argument error' do
        expect { hello.typed_arg }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_arg_without_body' do
    it 'returns nil' do
      expect(hello.typed_arg_without_body('Hola')).to eq(nil)
    end

    context 'when no arg provided' do
      let(:error_message) { "Invalid argument type 'NilClass' for parameter 'greeting'. Valid types: 'String'" }

      it 'raises an argument error' do
        expect { hello.typed_arg_without_body }.to raise_error(Low::ArgumentTypeError, error_message)
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

  describe '#typed_arg_and_invalid_default_value' do
    it 'passes through the argument' do
      expect(hello.typed_arg_and_invalid_default_value('Howdy')).to eq('Howdy')
    end

    context 'when no arg provided' do
      let(:error_message) { "Invalid argument type 'Integer' for parameter 'greeting'. Valid types: 'String'" }

      it 'raises an argument type error' do
        # => raises Low::ArgumentTypeError. A default value that is not nil still has to be an allowed type.
        expect { hello.typed_arg_and_invalid_default_value }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end

  # Multiple types.

  describe '#multiple_typed_args' do
    it 'passes through both arguments types' do
      expect(hello.multiple_typed_args('Shalom')).to eq('Shalom')
      expect(hello.multiple_typed_args(123)).to eq(123)
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'TrueClass' for parameter 'greeting'. Valid types: 'String | Integer'"
      end

      it 'raises an invalid type error' do
        expect { hello.multiple_typed_args(true) }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg is provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greeting'. Valid types: 'String | Integer'"
      end

      it 'raises an argument error' do
        expect { hello.multiple_typed_args }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#multiple_typed_args_and_default_value' do
    it 'passes through both arguments types' do
      expect(hello.multiple_typed_args_and_default_value('Shalom')).to eq('Shalom')
      expect(hello.multiple_typed_args_and_default_value(123)).to eq(123)
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'TrueClass' for parameter 'greeting'. Valid types: 'String | Integer'"
      end

      it 'raises an argument type error' do
        expect do
          hello.multiple_typed_args_and_default_value(true)
        end.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg is provided' do
      it 'provides the default value' do
        expect(hello.multiple_typed_args_and_default_value).to eq('Salutations')
      end
    end
  end
end
