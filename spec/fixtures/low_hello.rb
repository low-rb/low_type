# frozen_string_literal: true

require_relative '../../lib/low_type'

class LowHello
  include LowType

  def initialize(greeting = String, name = String)
    @greeting = greeting
    @name = name
  end

  def typed_arg(greeting = String)
    greeting
  end

  def typed_arg_without_body(greeting = String)
    # LowType should still validate the param without erroring.
  end

  def typed_arg_and_default_value(greeting = String | 'Hello')
    greeting
  end

  def typed_arg_and_invalid_default_value(greeting = String | 123)
    # => raises TypeError. A default value that is not nil still has to be a valid type.
    greeting
  end

  # Types as values.

  def typed_arg_and_typed_default_value(greeting = String | value(String))
    greeting
  end

  def typed_arg_and_invalid_default_typed_value(greeting = String | Array[Symbol] | value(Integer))
    # => raises TypeError. A default value(type) that is not nil still has to be a valid type.
    greeting
  end

  # Multiple types.

  def multiple_typed_args(greeting = String | Integer)
    greeting
  end

  def multiple_typed_args_and_default_value(greeting = String | Integer | 'Salutations')
    greeting
  end

  # Enumerables.

  def typed_array_arg(greetings = Array[String])
    greetings
  end

  def typed_nilable_array_arg(goodbyes = Array[String | nil])
    goodbyes
  end

  def typed_nilable_array_arg_and_default_nil(greetings = Array[String | nil] | nil)
    greetings
  end

  def typed_array_arg_and_default_nil(greetings = Array[String] | nil)
    greetings
  end

  def typed_array_arg_and_default_value(greetings = Array[String] | %w[Hi Hey Howdy])
    greetings
  end

  # Return types.

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

  # Class methods.

  def self.inline_class_typed_arg(goodbye = String)
    goodbye
  end

  class << self
    def class_typed_arg(goodbye = String)
      goodbye
    end

    def class_typed_arg_and_default_value(goodbye = String | 'Bye')
      goodbye
    end
  end

  private

  def private_typed_arg(greeting = String)
    greeting
  end
end
