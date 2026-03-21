# frozen_string_literal: true

require_relative '../../../lib/types/boolean'

RSpec.describe Low::Types::Boolean do
  describe '.match?' do
    it 'accepts true' do
      expect(described_class.match?(value: true)).to be true
    end

    it 'accepts false' do
      expect(described_class.match?(value: false)).to be true
    end

    it 'rejects nil' do
      expect(described_class.match?(value: nil)).to be false
    end

    it 'rejects string "true"' do
      expect(described_class.match?(value: 'true')).to be false
    end

    it 'rejects integer 0' do
      expect(described_class.match?(value: 0)).to be false
    end
  end
end
