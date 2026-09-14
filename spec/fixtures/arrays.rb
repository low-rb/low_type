# frozen_string_literal: true

require_relative '../../lib/lowtype'

class Arrays
  include LowType

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
end
