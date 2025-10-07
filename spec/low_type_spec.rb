# frozen_string_literal: true

require_relative 'fixtures/low_hello.rb'

RSpec.describe LowHello do
  it 'instantiates a class with types' do
    expect { described_class.new('POSITIONAL_ARG', 'Hey', generic_name: 'Mate') }.not_to raise_error
  end

  it 'raises an error with incorrect types' do
    expect { described_class.new('POSITIONAL_ARG', 123, generic_name: 'Mate') }.to raise_error(LowType::InvalidType)
  end
end
