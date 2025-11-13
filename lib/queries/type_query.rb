module LowType
  # TODO: Unit test.
  class TypeQuery
    class << self
      def type?(type)
        basic_type?(type:) || complex_type?(type:)
      end

      def basic_type?(type:)
        type.class == Class
      end

      def complex_type?(type:)
        !basic_type?(type:) && typed_hash?(type:)
      end

      def typed_hash?(type:)
        type.is_a?(::Hash) && basic_type?(type: type.keys.first) && basic_type?(type: type.values.first)
      end

      def value?(expression)
        !expression.respond_to?(:new) && expression != Integer
      end
    end
  end
end
