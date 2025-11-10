# frozen_string_literal: true

require_relative '../fixtures/main_object'

RSpec.describe 'main object' do
  describe '#arg' do
    it 'passes through the argument' do
      expect(arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'raises an argument error' do
        expect { arg }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#arg_and_default_value' do
    it 'passes through the argument' do
      expect(arg_and_default_value('Howdy')).to eq('Howdy')
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(arg_and_default_value).to eq('Hello')
      end
    end
  end

  describe '#typed_arg' do
    it 'passes through the argument' do
      expect(typed_arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      let(:error_message) { "Invalid argument type 'NilClass' for parameter 'greeting'. Valid types: 'String'" }

      it 'raises an argument error' do
        expect { typed_arg }.to raise_error(LowType::ArgumentTypeError, error_message)
      end
    end
  end

  describe '#private_arg' do
    # It makes no difference as all methods defined on main object are private.
    it 'does not raise no method error' do
      expect(private_arg).to eq('Goodbye')
    end
  end
end
