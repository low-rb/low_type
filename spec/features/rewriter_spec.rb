# frozen_string_literal: true

require_relative '../fixtures/rewriter'

RSpec.describe 'rewrite_methods (type_checking: :rewrite)' do
  subject(:instance) { RewriterFixture.new }

  after(:all) { LowType.configure { |c| c.type_checking = true } }

  # -------------------------------------------------------------------------
  # Required positional
  # -------------------------------------------------------------------------
  describe '#positional_required' do
    it 'accepts a correct-type argument' do
      expect(instance.positional_required('Alice')).to eq('Alice')
    end

    it 'accepts a wrong-type argument without raising' do
      expect { instance.positional_required(42) }.not_to raise_error
    end
  end

  # -------------------------------------------------------------------------
  # Optional positional with ValueExpression default
  # -------------------------------------------------------------------------
  describe '#positional_with_default' do
    it 'returns the passed value' do
      expect(instance.positional_with_default(5)).to eq(5)
    end

    it 'uses the unwrapped default value when no arg given' do
      expect(instance.positional_with_default).to eq(0)
    end
  end

  # -------------------------------------------------------------------------
  # Required keyword
  # -------------------------------------------------------------------------
  describe '#keyword_required' do
    it 'accepts a correct-type keyword argument' do
      expect(instance.keyword_required(name: 'Bob')).to eq('Bob')
    end

    it 'accepts a wrong-type keyword argument without raising' do
      expect { instance.keyword_required(name: 123) }.not_to raise_error
    end
  end

  # -------------------------------------------------------------------------
  # Optional keyword with ValueExpression default
  # -------------------------------------------------------------------------
  describe '#keyword_with_default' do
    it 'returns the passed keyword value' do
      expect(instance.keyword_with_default(greeting: 'Hi')).to eq('Hi')
    end

    it 'uses the unwrapped default value when no kwarg given' do
      expect(instance.keyword_with_default).to eq('Hello')
    end
  end

  # -------------------------------------------------------------------------
  # No params
  # -------------------------------------------------------------------------
  describe '#no_params' do
    it 'works correctly with no arguments' do
      expect(instance.no_params).to eq('ok')
    end
  end

  # -------------------------------------------------------------------------
  # Class method
  # -------------------------------------------------------------------------
  describe '.class_method' do
    it 'rewrites and calls the class method correctly' do
      expect(RewriterFixture.class_method('MyLabel')).to eq('MyLabel')
    end

    it 'accepts wrong-type argument without raising' do
      expect { RewriterFixture.class_method(99) }.not_to raise_error
    end
  end

  # -------------------------------------------------------------------------
  # Private method visibility preserved
  # -------------------------------------------------------------------------
  describe '#private_method' do
    it 'remains private after rewrite' do
      expect { instance.private_method('secret') }.to raise_error(NoMethodError)
    end

    it 'is still callable internally' do
      expect(instance.send(:private_method, 'secret')).to eq('secret')
    end
  end
end
