# frozen_string_literal: true

require_relative 'fixtures/low_hello.rb'

RSpec.describe LowHello do
  subject(:hello) { described_class.new(greeting, name:) }

  let(:greeting) { 'Hey' }
  let(:name) { 'Mate' }

  describe '#initialize' do
    it 'instantiates a typed class' do
      expect { hello }.not_to raise_error
    end

    context 'when the arg type is incorrect' do
      let(:greeting) { 123 }

      it 'raises an invalid type error' do
        expect { hello }.to raise_error(LowType::InvalidType)
      end
    end
  end

  describe '#say_hello' do
    it 'handles a type expression with a default value' do
      expect(hello.say_hello('Hi')).to eq('Hi')
    end

    context 'when no arg provided' do
      it 'provides a default value' do
        expect(hello.say_hello).to eq('Hello')
      end
    end
  end
end
