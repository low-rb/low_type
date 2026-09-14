# frozen_string_literal: true

require_relative '../../lib/lowtype'

class ValueExpressions
  include LowType

  def typed_arg_and_typed_default_value(greeting = String | value(String))
    greeting
  end

  def typed_arg_and_invalid_default_typed_value(greeting = String | Array[Symbol] | value(Integer))
    # => raises TypeError... a default value(T) that is not nil still has to be a valid type.
    greeting
  end
end
