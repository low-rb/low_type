# frozen_string_literal: true

require_relative '../queries/type_query'

module LowType
  module Syntax
    refine Array.singleton_class do
      def [](*expression)
        return TypeExpression.new(type: [*expression]) if TypeQuery.type?(expression.first) || TypeQuery.typed_array?(expression:)

        super
      end
    end

    refine Hash.singleton_class do
      def [](type)
        return TypeExpression.new(type:) if TypeQuery.type?(type)

        super
      end
    end
  end
end
