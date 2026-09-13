# frozen_string_literal: true

require_relative '../fixtures/hashes'

RSpec.describe Hashes do
  subject { Hashes.new(hash:) }

  let(:hash) { { 'Hello' => 'Goodbye' } }

  describe '#initialize' do
    it 'instantiates a typed class' do
      expect { subject }.not_to raise_error
    end

    context 'when the arg type is incorrect' do
      let(:hash) { 123 }
      let(:error_message) { "Invalid argument type 'Integer' for parameter 'hash'. Valid types: '{String => String}'" }

      it 'raises an invalid type error' do
        expect { subject }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_hash_arg' do
    it 'passes through the argument' do
      expect(subject.typed_hash_arg({ 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'Hash' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argumment type error' do
        expect { subject.typed_hash_arg({ 123 => 456 }) }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argument error' do
        expect { subject.typed_hash_arg }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_hash_kwarg' do
    it 'passes through the argument' do
      expect(subject.typed_hash_kwarg(greetings: { 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'Hash' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argumment type error' do
        expect { subject.typed_hash_kwarg(greetings: { 123 => 456 }) }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argument error' do
        expect { subject.typed_hash_kwarg }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#typed_hash_arg_and_default_value' do
    it 'passes through the argument' do
      expect(subject.typed_hash_arg_and_default_value({ 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(subject.typed_hash_arg_and_default_value).to eq({ 'Hola' => 'Adios' })
      end
    end
  end

  describe '#typed_hash_arg_and_hash_empty_value' do
    it 'accepts empty hash argument as default value' do
      expect(subject.typed_hash_arg_and_hash_empty_value({})).to eq({})
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(subject.typed_hash_arg_and_hash_empty_value).to eq({})
      end
    end
  end

  describe '#typed_hash_arg_and_key_value_hash_empty_value' do
    it 'accepts empty hash argument as default value' do
      expect(subject.typed_hash_arg_and_key_value_hash_empty_value({})).to eq({})
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(subject.typed_hash_arg_and_key_value_hash_empty_value).to eq({})
      end
    end
  end

  describe '#typed_hash_kwarg' do
    it 'passes through the argument' do
      expect(subject.typed_hash_kwarg(greetings: { 'Hello' => 'Goodbye' })).to eq({ 'Hello' => 'Goodbye' })
    end

    context 'when arg is wrong type' do
      let(:error_message) do
        "Invalid argument type 'Hash' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argumment type error' do
        expect { subject.typed_hash_kwarg(greetings: { 123 => 456 }) }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'NilClass' for parameter 'greetings'. Valid types: '{String => String}'"
      end

      it 'raises an argument error' do
        expect { subject.typed_hash_kwarg }.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#type_accessor with Hash[String => Integer] | {}' do
    subject(:hash) { HashWithTypeAccessor.new(value:) }

    context 'with empty arg' do
      let(:value) { {} }

      it 'sets empty value' do
        expect(hash.value = {}).to eq({})
      end
    end

    context 'with valid types' do
      let(:value) { { 'valid' => 123 } }

      it 'sets valid value' do
        expect(hash.value = value).to eq(value)
      end
    end

    context 'with invalid types' do
      let(:value) { { 123 => 'invalid' } }

      context 'when getting' do
        let(:error_message) do
          "Invalid argument type 'Hash' for parameter 'value'. Valid types: '{String => Integer}'"
        end

        it 'raises an argument type error' do
          expect { hash.value = value }.to raise_error(Low::ArgumentTypeError, error_message)
        end
      end

      context 'when setting' do
        let(:error_message) do
          "Invalid return type 'Hash' for method 'value'. Valid types: '{String => Integer}'"
        end

        it 'raises a return type error' do
          expect { hash.value }.to raise_error(Low::ReturnTypeError, error_message)
        end
      end
    end
  end
end
