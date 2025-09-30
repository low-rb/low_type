# frozen_string_literal: true

require_relative 'fixtures/hello_world.rb'

RSpec.describe HelloWorld do
  it 'instantiates a class with types' do
    described_class.new(greeting: 'Hi')

    expect { described_class }.not_to raise_error
  end
end
