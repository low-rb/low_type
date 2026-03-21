# frozen_string_literal: true

require_relative '../fixtures/boolean_and_enum'

RSpec.describe BooleanAndEnum do
  subject(:instance) { described_class.new }

  describe '#boolean_arg' do
    it 'accepts true' do
      expect(instance.boolean_arg(flag: true)).to be true
    end

    it 'accepts false' do
      expect(instance.boolean_arg(flag: false)).to be false
    end

    it 'raises on invalid type' do
      expect { instance.boolean_arg(flag: 'true') }.to raise_error(Low::ArgumentTypeError)
    end

    it 'raises when required arg is missing' do
      expect { instance.boolean_arg }.to raise_error(Low::ArgumentTypeError)
    end
  end

  describe '#boolean_with_default' do
    it 'uses default when nil' do
      expect(instance.boolean_with_default).to be true
    end

    it 'accepts explicit false' do
      expect(instance.boolean_with_default(flag: false)).to be false
    end
  end

  describe '#enum_arg' do
    it 'accepts allowed symbol' do
      expect(instance.enum_arg(status: :draft)).to eq(:draft)
    end

    it 'raises on disallowed value' do
      expect { instance.enum_arg(status: :invalid) }.to raise_error(Low::ArgumentTypeError)
    end

    it 'raises when required arg is missing' do
      expect { instance.enum_arg }.to raise_error(Low::ArgumentTypeError)
    end
  end

  describe '#enum_with_default' do
    it 'uses default when nil' do
      expect(instance.enum_with_default).to eq(:draft)
    end

    it 'accepts explicit allowed value' do
      expect(instance.enum_with_default(status: :published)).to eq(:published)
    end
  end
end
