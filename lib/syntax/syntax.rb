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
