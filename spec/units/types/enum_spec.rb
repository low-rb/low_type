# frozen_string_literal: true

require_relative '../../../lib/types/enum'

RSpec.describe Low::Types::Enum do
  describe '.[]' do
    it 'returns a Definition' do
      expect(described_class[1, 2, 3]).to be_a(Low::Types::Enum::Definition)
    end

    it 'Definition#match? accepts allowed values' do
      defn = described_class[:a, :b, :c]
      expect(defn.match?(value: :a)).to be true
      expect(defn.match?(value: :b)).to be true
    end

    it 'Definition#match? rejects disallowed values' do
      defn = described_class[:a, :b, :c]
      expect(defn.match?(value: :d)).to be false
    end

    it 'inspect returns readable form' do
      defn = described_class[:draft, :published]
      expect(defn.inspect).to include('Enum')
      expect(defn.inspect).to include('draft')
    end
  end
end
