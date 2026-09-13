# frozen_string_literal: true

require_relative '../fixtures/inheritance'

RSpec.describe 'Subclass type inheritance' do
  # Test plan item 1: Subclass instance accepted for parent type
  context 'direct subclass (Dog for Animal)' do
    subject(:kennel) { Kennel.new }

    it 'accepts the exact type' do
      expect(kennel.admit(pet: Animal.new)).to eq('Welcome, Animal!')
    end

    it 'accepts a subclass instance without raising' do
      expect { kennel.admit(pet: Dog.new) }.not_to raise_error
    end

    it 'returns the correct greeting for the subclass' do
      expect(kennel.admit(pet: Dog.new)).to eq('Welcome, Dog!')
    end
  end

  # Test plan item 2: Multi-level inheritance
  context 'multi-level inheritance (GoldenRetriever < Dog < Animal)' do
    subject(:kennel) { Kennel.new }

    it 'accepts a grandchild subclass instance without raising' do
      expect { kennel.admit(pet: GoldenRetriever.new) }.not_to raise_error
    end

    it 'returns the correct greeting for the grandchild subclass' do
      expect(kennel.admit(pet: GoldenRetriever.new)).to eq('Welcome, GoldenRetriever!')
    end
  end

  # Test plan item 3: Core Ruby hierarchies
  context 'core Ruby hierarchy (Integer for Numeric)' do
    subject(:store) { NumericStore.new }

    it 'accepts an Integer for a Numeric parameter' do
      expect { store.save(value: 42) }.not_to raise_error
    end

    it 'accepts a Float for a Numeric parameter' do
      expect { store.save(value: 3.14) }.not_to raise_error
    end

    it 'rejects a non-Numeric value' do
      expect { store.save(value: 'not a number') }.to raise_error(Low::ArgumentTypeError)
    end
  end

  context 'when reading a file' do
    subject(:reader) { IOReader.new }

    it 'accepts a File instance arg for an IO typed parameter (File is a subclass of IO)' do
      file = File.open(__FILE__, 'r')
      expect { reader.read(source: file) }.not_to raise_error
      file.close
    end
  end

  # Test plan item 4: No regressions — wrong type still raises
  context 'regression: unrelated type still raises' do
    subject(:kennel) { Kennel.new }

    it 'raises Low::ArgumentTypeError for a completely unrelated type' do
      expect { kennel.admit(pet: 'not an animal') }.to raise_error(Low::ArgumentTypeError)
    end

    it 'raises Low::ArgumentTypeError for an Integer' do
      expect { kennel.admit(pet: 42) }.to raise_error(Low::ArgumentTypeError)
    end
  end
end
