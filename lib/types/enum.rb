# frozen_string_literal: true

module Low
  module Types
    # Enum[val1, val2, ...] creates a type that accepts only the listed values.
    # Usage: def foo(status: Enum[:draft, :published, :archived])
    module Enum
      class Definition
        attr_reader :allowed_values

        def initialize(allowed_values)
          @allowed_values = allowed_values.freeze
        end

        def match?(value:)
          @allowed_values.include?(value)
        end

        # Support union/default syntax: Enum[:a, :b] | :a or Enum[:a, :b] | nil
        def |(expression)
          ::Low::TypeExpression.new(type: self) | expression
        end

        def inspect
          "Enum[#{@allowed_values.map(&:inspect).join(', ')}]"
        end
      end

      def self.[](*allowed_values)
        Definition.new(allowed_values)
      end
    end
  end
end
