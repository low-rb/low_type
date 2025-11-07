# frozen_string_literal: true

module LowType
  module Syntax
    refine Array.singleton_class do
      def [](*types)
        return LowType::TypeExpression.new(type: [*types]) if types.all? { |type| LowType.type?(type) }

        super
      end
    end

    refine Hash.singleton_class do
      def [](type)
        return LowType::TypeExpression.new(type:) if LowType.type?(type)

        super
      end
    end
  end
end

# Refine doesn't support inheritence.
class Object
  # For "Type | [type_expression/type/value]" situations, redirecting to or generating a type expression from types.
  # "|" is not defined on Object class and this is the most compute-efficient way to achieve our goal (world peace).
  # "|" is overridable by any child object. While we could def/undef this method, this approach is actually lighter.
  # "|" bitwise operator on Integer is not defined when the receiver is an Integer class, so we are not in conflict.
  class << self
    def |(expression)
      if expression.instance_of?(::LowType::TypeExpression)
        # We pass our type into their type expression.
        expression | self
        expression
      else
        # We turn our type into a type expression and pass in their [type_expression/type/value].
        type_expression = ::LowType::TypeExpression.new(type: self)
        type_expression | expression
      end
    end
  end
end
