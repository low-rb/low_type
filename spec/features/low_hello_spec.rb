# frozen_string_literal: true

require_relative '../../lib/error_types'
require_relative '../fixtures/low_hello'

RSpec.describe LowHello do
  subject(:hello) { described_class.new(greeting, name) }

  let(:greeting) { 'Hey' }
  let(:name) { 'Mate' }

  describe '.included' do
    it 'redefines methods on class load' do
      expect(described_class.low_methods.keys).to include(
        :initialize,
        :typed_arg,
        :typed_arg_without_body,
        :typed_arg_and_default_value,
        :typed_arg_and_invalid_default_value,
        :typed_arg_and_typed_default_value,
        :typed_arg_and_invalid_default_typed_value,
        :multiple_typed_args,
        :multiple_typed_args_and_default_value,
        :typed_array_arg,
        :typed_hash_arg,
        :typed_hash_arg_and_default_value,
        :return_type,
        :array_return_type,
        :arg_and_return_type,
        :arg_and_nilable_return_value,
        :private_typed_arg,
        :inline_class_typed_arg,
        :class_typed_arg,
        :class_typed_arg_and_default_value
      )
    end
  end

  describe '#initialize' do
    it 'instantiates a typed class' do
      expect { hello }.not_to raise_error
    end

    context 'when the arg type is incorrect' do
      let(:greeting) { 123 }
      let(:error_message) { "Invalid argument type 'Integer' for parameter 'greeting'. Valid types: 'String'" }

      it 'raises an invalid type error' do
        expect { hello }.to raise_error(LowType::ArgumentTypeError, error_message)
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
        expect { hello.typed_arg }.to raise_error(LowType::ArgumentTypeError, error_message)
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
        expect { hello.typed_arg_without_body }.to raise_error(LowType::ArgumentTypeError, error_message)
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
        # => raises LowType::ArgumentTypeError. A default value that is not nil still has to be an allowed type.
        expect { hello.typed_arg_and_invalid_default_value }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  # Types as values.

  describe '#typed_arg_and_typed_default_value' do
    it 'passes through the value(Type) argument' do
      expect(hello.typed_arg_and_typed_default_value('Howdy')).to eq('Howdy')
    end

    context 'when no arg provided' do
      it 'provides the default value (which is a type)' do
        expect(hello.typed_arg_and_typed_default_value).to eq(String)
      end
    end
  end

  describe '#typed_arg_and_invalid_default_typed_value' do
    it 'passes through the argument' do
      expect(hello.typed_arg_and_invalid_default_typed_value('Howdy')).to eq('Howdy')
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'Integer' for parameter 'greeting'. Valid types: '[Symbol] | String'"
      end

      it 'raises an argument type error' do
        # => raises LowType::ArgumentTypeError. A default value(type) that is not nil still has to be an allowed type.
        expect do
          hello.typed_arg_and_invalid_default_typed_value
        end.to raise_error(LowType::ArgumentTypeError, error_message)
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
        expect { hello.multiple_typed_args(true) }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg is provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greeting'. Valid types: 'String | Integer'"
      end

      it 'raises an argument error' do
        expect { hello.multiple_typed_args }.to raise_error(LowType::ArgumentTypeError, error_message)
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
        end.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg is provided' do
      it 'provides the default value' do
        expect(hello.multiple_typed_args_and_default_value).to eq('Salutations')
      end
    end
  end

  # Enumerables.

  describe '#typed_array_arg' do
    it 'passes through the argument' do
      expect(hello.typed_array_arg(%w[Hi Hey Howdy])).to eq(%w[Hi Hey Howdy])
    end

    context 'when no arg provided' do
      let(:error_message) { "Invalid argument type 'NilClass' for parameter 'greetings'. Valid types: '[String]'" }

      it 'raises an argument error' do
        expect { hello.typed_array_arg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_hash_arg' do
    it 'passes through the argument' do
      expect(hello.typed_hash_arg({ 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'Hash' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argumment type error' do
        expect { hello.typed_hash_arg({ 123 => 456 }) }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argument error' do
        expect { hello.typed_hash_arg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_hash_arg_and_default_value' do
    it 'passes through the argument' do
      expect(hello.typed_hash_arg_and_default_value({ 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(hello.typed_hash_arg_and_default_value).to eq({ 'Hola' => 'Adios' })
      end
    end
  end

  # Return types.

  describe '#return_type' do
    it 'returns a value' do
      expect(hello.return_type).to eq(4)
    end

    it 'defines return type expression' do
      hello.return_type
      expect(described_class.low_methods[:return_type].return_proxy.type_expression.types).to eq([Integer])
    end
  end

  describe '#array_return_type' do
    it 'returns an array of symbols' do
      expect(hello.array_return_type).to eq(%i[one two three])
    end

    it 'defines Array[Symmbol] return type expression' do
      hello.array_return_type
      expect(described_class.low_methods[:array_return_type].return_proxy.type_expression.types).to eq([Array[Symbol]])
    end
  end

  describe '#arg_and_return_type' do
    it 'defines return type expression' do
      hello.arg_and_return_type('Morning')
      expect(described_class.low_methods[:arg_and_return_type].return_proxy.type_expression.types).to eq([String])
    end

    context 'when the return value is nil' do
      let(:error_message) { "Invalid return type 'NilClass' for method 'arg_and_return_type'. Valid types: 'String'" }

      it 'raises a return type error' do
        expect { hello.arg_and_return_type(nil) }.to raise_error(LowType::ReturnTypeError, error_message)
      end
    end

    context 'when the return value does not validate the return type expression' do
      let(:error_message) { "Invalid return type 'Integer' for method 'arg_and_return_type'. Valid types: 'String'" }

      it 'raises a return type error' do
        expect { hello.arg_and_return_type(123) }.to raise_error(LowType::ReturnTypeError, error_message)
      end
    end
  end

  describe '#arg_and_nilable_return_value' do
    it 'defines return type expression' do
      expect(hello.arg_and_nilable_return_value(nil)).to eq(nil)
      expect(described_class.low_methods[:arg_and_nilable_return_value].return_proxy.type_expression.types).to eq([String])
    end

    context 'when the return value does not validate the return type expression' do
      let(:error_message) do
        "Invalid return type 'Integer' for method 'arg_and_nilable_return_value'. Valid types: 'String | nil'"
      end

      it 'raises a return type error' do
        expect { hello.arg_and_nilable_return_value(123) }.to raise_error(LowType::ReturnTypeError, error_message)
      end
    end
  end

  # Class methods.

  describe '.inline_class_typed_arg' do
    it 'passes through the argument' do
      expect(described_class.inline_class_typed_arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      let(:error_message) { "Invalid argument type 'NilClass' for parameter 'goodbye'. Valid types: 'String'" }

      it 'raises an argument error' do
        expect { described_class.inline_class_typed_arg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '.class_typed_arg' do
    it 'passes through the argument' do
      expect(described_class.class_typed_arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      let(:error_message) { "Invalid argument type 'NilClass' for parameter 'goodbye'. Valid types: 'String'" }

      it 'raises an argument error' do
        expect { described_class.class_typed_arg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '.class_typed_arg_and_default_value' do
    it 'passes through the argument' do
      expect(described_class.class_typed_arg_and_default_value('Goodbye')).to eq('Goodbye')
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(described_class.class_typed_arg_and_default_value).to eq('Bye')
      end
    end
  end

  describe '#private_typed_arg' do
    let(:error_message) { "private method 'private_typed_arg' called for an instance of LowHello" }

    it 'raises no method error' do
      expect { hello.private_typed_arg }.to raise_error(NoMethodError, error_message)
    end
  end
end
