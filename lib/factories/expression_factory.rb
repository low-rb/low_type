# frozen_string_literal: true

require_relative '../expressions/type_expression'
require_relative '../expressions/value_expression'

module LowType
  class ExpressionFactory
    class << self
      def type_expression_with_value(type:)
        TypeExpression.new(default_value: ValueExpression.new(value: type))
      end
    end
  end
end
