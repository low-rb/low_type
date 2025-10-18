# frozen_string_literal: true

require_relative '../lib/errors'
require_relative 'fixtures/type_assigner'

LowType.configure do |config|
  config.type_assignment = true
end

RSpec.describe TypeAssigner do
  subject { described_class.new }

  describe '#initialize' do
    it 'instantiates a class' do
      expect { subject }.not_to raise_error
    end
  end

  # Runtime type expression.

  describe '#assign_typed_array' do
    it 'assigns a typed array' do
      expect(subject.assign_typed_array).to eq([1, 2, 3])
    end

    context 'when the type is wrong' do
      let(:error_message) { "Invalid variable type Array in 'TypeAssigner' on line 27. Valid types: '[Integer]'" }
  
      it 'raises an argument type error' do
        expect { subject.assign_invalid_typed_array }.to raise_error(LocalTypeError, error_message)
      end
    end
  end

  # Runtime value expression.

  describe '#assign_typed_default_value' do
    it 'passes through the value(Type) argument' do
      subject.assign_typed_default_value
      expect(subject.typed_default_value).to eq(String)
    end
  end

  # Assignment and re-assignment.

  describe '#assign_typed_instance_variable' do
    it 'assigns a typed instance variable' do
      subject.assign_typed_instance_variable
      expect(subject.typed_instance_variable.class).to eq(MyType)
    end
  end

  describe '#reassign_typed_instance_variable' do
    it 're-assigns a typed instance variable' do
      subject.assign_typed_instance_variable
      subject.reassign_typed_instance_variable
      expect(subject.typed_instance_variable.id).to eq('reassigned')
    end
  end

  describe '#reassign_invalid_typed_instance_variable' do
    it 'raises a type error' do
      subject.assign_typed_instance_variable
      expect { subject.reassign_invalid_typed_instance_variable }.to raise_error(TypeError)
    end
  end
end
