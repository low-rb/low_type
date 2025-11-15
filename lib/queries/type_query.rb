# frozen_string_literal: true

require_relative '../type_expression'

module LowType
  # TODO: Unit test.
  class TypeQuery
    class << self
      def type?(type)
        basic_type?(type:) || complex_type?(type:)
      end

      def value?(value)
        !basic_type?(type: value) && !complex_type?(type: value)
      end

      def complex_type?(type:)
        LowType::COMPLEX_TYPES.include?(type) || typed_array?(type:) || typed_hash?(type:)
      end

      private

      def basic_type?(type:)
        type.instance_of?(Class)
      end

      def typed_array?(type:)
        type.is_a?(Array) && (basic_type?(type: type.first) || type.first.is_a?(TypeExpression))
      end

      def typed_hash?(type:)
        type.is_a?(Hash) && basic_type?(type: type.keys.first) && basic_type?(type: type.values.first)
      end
    end
  end
end
