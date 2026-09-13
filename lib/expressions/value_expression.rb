# frozen_string_literal: true

module Low
  # A value expression presents a type as a value:
  #   1. It is an instance
  #   2. It mimics the class method
  class ValueExpression
    attr_reader :value

    def initialize(value:)
      @value = value
    end

    def class
      @value
    end
  end
end
