# frozen_string_literal: true

require_relative '../lib/types/error_types'
require_relative 'fixtures/low_local'

RSpec.describe LowLocal do
  subject { described_class.new }

  describe '#initialize' do
    it 'instantiates a class' do
      expect { subject }.not_to raise_error
    end
  end

  # Runtime type expression.

  describe '#local_type_array' do
    it 'assigns a typed array' do
      expect(subject.local_type_array).to eq([1, 2, 3])
    end

    context 'when the type is wrong' do
      let(:error_message) { "Invalid variable type Array in 'LowLocal' on line 30. Valid types: '[Integer]'" }

      it 'raises an argument type error' do
        expect { subject.invalid_local_type_array }.to raise_error(LowType::LocalTypeError, error_message)
      end
    end

    context 'when the class is missing syntax refinements' do
      subject { LowLocalWithoutSyntax.new }

      let(:error_message) { "Invalid type expression, likely because you didn't add 'using LowType::Syntax'" }

      it 'raises a config error' do
        expect { subject.local_type_array }.to raise_error(LowType::ConfigError, error_message)
      end
    end
  end

  describe '#array_multiple_subtypes' do
    it 'assigns a sub typed array' do
      expect(subject.array_multiple_subtypes).to eq([1, '2', :three])
    end

    context 'when the type is wrong' do
      let(:error_message) do
        "Invalid variable type Array in 'LowLocal' on line 38. Valid types: '[Integer, String, Symbol]'"
      end

      it 'raises an argument type error' do
        expect { subject.invalid_array_multiple_subtypes }.to raise_error(LowType::LocalTypeError, error_message)
      end
    end
  end

  # Runtime value expression.

  describe '#local_type_default_value' do
    it 'passes through the value(Type) argument' do
      subject.local_type_default_value
      expect(subject.typed_default_value).to eq(String)
    end
  end

  # Assignment and re-assignment.

  describe '#local_type_instance_variable' do
    it 'assigns a typed instance variable' do
      subject.local_type_instance_variable
      expect(subject.typed_instance_variable.class).to eq(MyType)
    end
  end
end
