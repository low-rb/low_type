# frozen_string_literal: true

require_relative 'fixtures/low_hello.rb'

RSpec.describe LowHello do
  it 'instantiates a class with types' do
    expect { described_class.new(greeting: 'Hi') }.not_to raise_error
  end
end
