# frozen_string_literal: true

require_relative '../lib/types/error_types'
require_relative 'fixtures/low_local'

RSpec.describe 'LocalTypes' do
  subject { LowLocal.new }

  describe '#initialize' do
    it 'instantiates a class' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#default_string' do
    it 'defines the type and returns the value' do
      expect(subject.default_string).to eq('Hello')
    end
  end

  describe '#default_method' do
    it 'defines the type and returns the value' do
      expect(subject.default_method).to eq('Goodbye')
    end

    context 'when the default value is an expression' do
      it 'evaluates the expression' do
        expect(subject.default_string_again).to eq('Hello Again')
      end
    end
  end

  describe '#default_typed_value' do
    it 'passes through the value(Type) argument' do
      subject.default_typed_value
      expect(subject.default_typed_value).to eq(String)
    end
  end

  describe '#subtype_array' do
    it 'assigns a typed array' do
      expect(subject.subtype_array).to eq([1, 2, 3])
    end

    context 'when the type is wrong' do
      let(:error_message) { /Invalid variable type Array in 'LowLocal' on line \d+. Valid types: '\[Integer\]'/ }

      it 'raises an argument type error' do
        expect { subject.invalid_subtype_array }.to raise_error(LowType::LocalTypeError, error_message)
      end
    end

    context 'when the class is missing syntax refinements' do
      subject { LowLocalWithoutRefinements.new }

      let(:error_message) { "Invalid type expression, likely because you didn't add 'using LowType::Syntax'" }

      it 'raises a config error' do
        expect { subject.subtype_array }.to raise_error(LowType::ConfigError, error_message)
      end
    end
  end

  describe '#array_multiple_subtypes' do
    it 'assigns a sub typed array' do
      expect(subject.array_multiple_subtypes).to eq([1, '2', :three])
    end

    context 'when the type is wrong' do
      let(:error_message) do
        /Invalid variable type Array in 'LowLocal' on line \d+. Valid types: '\[Integer, String, Symbol\]'/
      end

      it 'raises an argument type error' do
        expect { subject.invalid_array_multiple_subtypes }.to raise_error(LowType::LocalTypeError, error_message)
      end
    end
  end
end
