# frozen_string_literal: true

# A value expression converts a type to a value in the eyes of LowType.
class ValueExpression
  attr_reader :value

  def initialize(value:)
    @value = value
  end

  def class
    @value
  end
end
