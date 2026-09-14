# frozen_string_literal: true

require_relative '../../lib/lowtype'

RSpec.describe 'LowType.config.type_checking' do
  context 'when type checking is disabled', type_checking: false do
    subject(:type_checking) { TypeCheckingDisabled.new }

    require_relative '../fixtures/type_checking_disabled'

    describe '#typed_arg' do
      it 'passes through the argument' do
        expect(type_checking.typed_arg('Hi')).to eq('Hi')
      end

      context 'when arg is correct type' do
        it 'accepts the typed arg' do
          expect { type_checking.typed_arg('Yo') }.not_to raise_error
        end
      end

      context 'when arg is wrong type' do
        it 'accepts the wrongly typed arg' do
          expect { type_checking.typed_arg(123) }.not_to raise_error
        end
      end
    end
  end

  context 'when type checking is enabled', type_checking: true do
    subject(:type_checking) { TypeCheckingEnabled.new }

    require_relative '../fixtures/type_checking_enabled'

    describe '#typed_arg' do
      it 'passes through the argument' do
        expect(type_checking.typed_arg('Hi')).to eq('Hi')
      end

      context 'when arg is correct type' do
        it 'accepts the typed arg' do
          expect { type_checking.typed_arg('Yo') }.not_to raise_error
        end
      end

      context 'when arg is wrong type' do
        it 'accepts the wrongly typed arg without raising' do
          expect { type_checking.typed_arg(123) }.not_to raise_error
        end
      end

      context 'when no arg provided' do
        it 'raises ArgumentError since no default value is defined' do
          expect { type_checking.typed_arg }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
