# frozen_string_literal: true

require_relative '../../lib/low_type'

RSpec.describe 'LowType.config.type_checking' do
  context 'when type_checking: true (typed methods)' do
    subject(:type_checking) { TypeCheckingEnabled.new }

    before(:all) do
      LowType.configure { |config| config.type_checking = true }
      require_relative '../fixtures/type_checking_enabled'
    end

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
        it 'raises an argument type error' do
          expect { type_checking.typed_arg(123) }.to raise_error(Low::ArgumentTypeError)
        end
      end
    end
  end

  context 'when type_checking: false (untyped shim)' do
    subject(:type_checking) { TypeCheckingDisabled.new }

    before(:all) do
      LowType.configure { |config| config.type_checking = false }
      require_relative '../fixtures/type_checking_disabled'
    end

    after(:all) { LowType.configure { |config| config.type_checking = true } }

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

  context 'when type_checking: :rewrite (rewrite_methods)' do
    subject(:type_checking) { TypeCheckingRewrite.new }

    before(:all) do
      LowType.configure { |config| config.type_checking = :rewrite }
      require_relative '../fixtures/type_checking_rewrite'
    end

    after(:all) { LowType.configure { |config| config.type_checking = true } }

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
