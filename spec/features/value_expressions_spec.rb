# frozen_string_literal: true

require_relative '../fixtures/value_expressions'

RSpec.describe ValueExpressions do
  subject { described_class.new }

  describe '#typed_arg_and_typed_default_value' do
    it 'passes through the value(Type) argument' do
      expect(subject.typed_arg_and_typed_default_value('Wassup')).to eq('Wassup')
    end

    context 'when no arg provided' do
      it 'provides the default value (which is a type)' do
        expect(subject.typed_arg_and_typed_default_value).to eq(String)
      end
    end
  end

  describe '#typed_arg_and_invalid_default_typed_value' do
    it 'passes through the argument' do
      expect(subject.typed_arg_and_invalid_default_typed_value('Wassup')).to eq('Wassup')
    end

    context 'when no arg provided' do
      let(:error_message) do
        "Invalid argument type 'Integer' for parameter 'greeting'. Valid types: 'String | [Symbol]'"
      end

      it 'raises an argument type error', type_checking: true do
        # => raises Low::ArgumentTypeError. A default value(type) that is not nil still has to be an allowed type.
        expect do
          subject.typed_arg_and_invalid_default_typed_value
        end.to raise_error(Low::ArgumentTypeError, error_message)
      end
    end
  end
end
