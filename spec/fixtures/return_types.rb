# frozen_string_literal: true

require_relative '../../lib/lowtype'

class ReturnTypes
  include LowType

  def return_type() -> { Integer }
    2 + 2
  end

  def array_return_type() -> { Array[Symbol] }
    %i[one two three]
  end

  def arg_and_return_type(greeting) -> { String }
    2 + 2
    greeting
  end

  def arg_and_nilable_return_value(greeting) -> { String | nil }
    greeting
  end
end
