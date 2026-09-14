# frozen_string_literal: true

require_relative '../../lib/types/error_types'
require_relative '../../lib/queries/file_query'
require_relative '../fixtures/return_types'

RSpec.describe ReturnTypes do
  subject { described_class.new }

  let(:class_proxy) { Lowkey['spec/fixtures/return_types.rb']['ReturnTypes'] }

  describe '#return_type' do
    it 'returns a value' do
      expect(subject.return_type).to eq(4)
    end

    it 'defines return type expression' do
      subject.return_type
      expect(class_proxy[:return_type].return_proxy.expression.types).to eq([Integer])
    end
  end

  describe '#array_return_type' do
    it 'returns an array of symbols' do
      expect(subject.array_return_type).to eq(%i[one two three])
    end

    it 'defines Array[Symmbol] return type expression' do
      subject.array_return_type
      expect(class_proxy[:array_return_type].return_proxy.expression.types).to eq([Array[Symbol]])
    end
  end

  describe '#arg_and_return_type' do
    it 'defines return type expression' do
      subject.arg_and_return_type('Morning')
      expect(class_proxy[:arg_and_return_type].return_proxy.expression.types).to eq([String])
    end

    context 'when the return value is nil' do
      let(:error_message) { "Invalid return type 'NilClass' for method 'arg_and_return_type'. Valid types: 'String'" }

      it 'raises a return type error', type_checking: true do
        expect { subject.arg_and_return_type(nil) }.to raise_error(Low::ReturnTypeError, error_message)
      end
    end

    context 'when the return value does not validate the return type expression' do
      let(:error_message) { "Invalid return type 'Integer' for method 'arg_and_return_type'. Valid types: 'String'" }

      it 'raises a return type error', type_checking: true do
        expect { subject.arg_and_return_type(123) }.to raise_error(Low::ReturnTypeError, error_message)
      end
    end
  end

  describe '#arg_and_nilable_return_value' do
    it 'defines return type expression' do
      expect(subject.arg_and_nilable_return_value(nil)).to eq(nil)
      expect(class_proxy[:arg_and_nilable_return_value].return_proxy.expression.types).to eq([String])
    end

    context 'when the return value does not validate the return type expression' do
      let(:error_message) do
        "Invalid return type 'Integer' for method 'arg_and_nilable_return_value'. Valid types: 'String | nil'"
      end

      it 'raises a return type error', type_checking: true do
        expect { subject.arg_and_nilable_return_value(123) }.to raise_error(Low::ReturnTypeError, error_message)
      end
    end
  end

  # TODO: Return type that is literally a type (should probably pass). Test both basic type and complex type.
end
