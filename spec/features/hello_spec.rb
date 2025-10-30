# frozen_string_literal: true

require_relative '../fixtures/hello'

RSpec.describe Hello do
  subject(:hello) { described_class.new(greeting, name) }

  let(:greeting) { 'Hey' }
  let(:name) { 'Mate' }

  describe '#initialize' do
    it 'instantiates a class' do
      expect { hello }.not_to raise_error
    end
  end

  describe '#arg' do
    it 'passes through the argument' do
      expect(hello.arg('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'raises an argument error' do
        expect { hello.arg }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#arg_and_default_value' do
    it 'passes through the argument' do
      expect(hello.arg_and_default_value('Howdy')).to eq('Howdy')
    end

    context 'when no arg provided' do
      it 'provides the default value' do
        expect(hello.arg_and_default_value).to eq('Hello')
      end
    end
  end

  describe '#private_arg' do
    it 'raises no method error' do
      expect { hello.private_arg }.to raise_error(NoMethodError)
    end
  end
end
