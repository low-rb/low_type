# frozen_string_literal: true

require_relative '../fixtures/low_hash'

RSpec.describe 'Hash[T]' do
  subject(:low_hash) { LowHash.new(hash:) }
  let(:hash) { { 'Hello' => 'Goodbye' } }

  describe '.included' do
    it 'redefines methods on class load' do
      expect(LowHash.low_methods.keys).to include(
        :typed_hash_arg,
        :typed_hash_arg_and_default_value
      )
    end
  end

  describe '#initialize' do
    it 'instantiates a typed class' do
      expect { low_hash }.not_to raise_error
    end

    context 'when the arg type is incorrect' do
      let(:hash) { 123 }
      let(:error_message) { "Invalid argument type 'Integer' for parameter 'hash'. Valid types: '{String => String}'" }

      it 'raises an invalid type error' do
        expect { low_hash }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_hash_arg' do
    it 'passes through the argument' do
      expect(low_hash.typed_hash_arg({ 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'Hash' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argumment type error' do
        expect { low_hash.typed_hash_arg({ 123 => 456 }) }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argument error' do
        expect { low_hash.typed_hash_arg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_hash_kwarg' do
    it 'passes through the argument' do
      expect(low_hash.typed_hash_kwarg(greetings: { 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'Hash' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argumment type error' do
        expect { low_hash.typed_hash_kwarg(greetings: { 123 => 456 }) }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argument error' do
        expect { low_hash.typed_hash_kwarg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_hash_arg_and_default_value' do
    it 'passes through the argument' do
      expect(low_hash.typed_hash_arg_and_default_value({ 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(low_hash.typed_hash_arg_and_default_value).to eq({ 'Hola' => 'Adios' })
      end
    end
  end

  describe '#typed_hash_kwarg' do
    it 'passes through the argument' do
      expect(low_hash.typed_hash_kwarg(greetings: { 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'Hash' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argumment type error' do
        expect { low_hash.typed_hash_kwarg(greetings: { 123 => 456 }) }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argument error' do
        expect { low_hash.typed_hash_kwarg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end
end
