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

  # Multiple types.

  describe '#multiple_typed_args' do
    it 'passes through both arguments types' do
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
    it 'passes through both arguments types' do
      expect(hello.multiple_typed_args_and_default_value('Shalom')).to eq('Shalom')
      expect(hello.multiple_typed_args_and_default_value(123)).to eq(123)
    end

    context 'when args are wrong type' do
      it 'raises a type error' do
        expect { hello.multiple_typed_args_and_default_value(true) }.to raise_error(TypeError)
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
      expect(hello.typed_array_arg(['Hi', 'Hey', 'Howdy'])).to eq(['Hi', 'Hey', 'Howdy'])
    end

    context 'when no arg provided' do
      it 'raises a required type error' do
        expect { hello.typed_array_arg }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#typed_hash_arg' do
    it 'passes through the argument' do
      expect(hello.typed_hash_arg({'Hello' => 'Goodbye'})).to eq({'Hello' => 'Goodbye'})
    end

    context 'when args are wrong type' do
      it 'raises a type error' do
        expect { hello.typed_hash_arg({123 => 456}) }.to raise_error(TypeError)
      end
    end

    context 'when no arg provided' do
      it 'raises a required type error' do
        expect { hello.typed_hash_arg }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#typed_hash_arg_and_default_value' do
    it 'passes through the argument' do
      expect(hello.typed_hash_arg_and_default_value({'Hello' => 'Goodbye'})).to eq({'Hello' => 'Goodbye'})
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(hello.typed_hash_arg_and_default_value).to eq({'Hola' => 'Adios'})
      end
    end
  end

  # Return values.

  describe '#return_value' do
    it 'returns a value' do
      expect(hello.return_value).to eq(4)
    end

    it 'defines return type expression' do
      hello.return_value
      expect(described_class.low_methods[:return_value].return_expression.types).to eq([Integer])
    end
  end

  describe '#arg_and_return_value' do
    it 'defines return type expression' do
      hello.arg_and_return_value('Morning')
      expect(described_class.low_methods[:arg_and_return_value].return_expression.types).to eq([String])
    end

    context 'when the return value is nil' do
      it 'raises a type error' do
        # TODO: This type expression error is actually coming from the return_expression but it doesn't know that. Make return type specific error.
        expect { hello.arg_and_return_value(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when the return value does not validate the return type expression' do
      it 'raises a type error' do
        expect { hello.arg_and_return_value(123) }.to raise_error(TypeError)
      end
    end
  end

  describe '#arg_and_nilable_return_value' do
    it 'defines return type expression' do
      hello.arg_and_nilable_return_value(nil)
      expect(described_class.low_methods[:arg_and_nilable_return_value].return_expression.types).to eq([String])
    end

    context 'when the return value does not validate the return type expression' do
      it 'raises a type error' do
        expect { hello.arg_and_nilable_return_value(123) }.to raise_error(TypeError)
      end
    end
  end

  # Class methods.

  describe '.inline_class_typed_arg' do
    it 'passes through the argument' do
      expect(described_class.inline_class_typed_arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'raises an argument error' do
        expect { described_class.inline_class_typed_arg }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.class_typed_arg' do
    it 'passes through the argument' do
      expect(described_class.class_typed_arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'raises an argument error' do
        expect { described_class.class_typed_arg }.to raise_error(ArgumentError)
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
    it 'raises no method error' do
      expect { hello.private_typed_arg }.to raise_error(NoMethodError)
    end
  end
end
