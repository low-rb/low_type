# frozen_string_literal: true

require_relative '../../lib/expressions/type_expression'

RSpec.describe LowType::TypeExpression do
  subject(:type_expression) { described_class.new(default_value: nil) }

  describe '#initialize' do
    it 'instantiates a class' do
      expect { type_expression }.not_to raise_error
    end
  end
end
