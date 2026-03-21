# frozen_string_literal: true

require_relative 'complex_type'

module Low
  module Types
    # Accepts only +true+ or +false+. Use instead of TrueClass | FalseClass union.
    class Boolean
      extend ComplexType

      def self.match?(value:)
        value == true || value == false
      end
    end
  end
end
