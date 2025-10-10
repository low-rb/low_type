require_relative '../../lib/low_type.rb'

class LowHello
  include LowType

  def initialize(greeting = String, name: String)
    @greeting = greeting
    @name = name
  end

  def with_type(greeting = String)
    greeting
  end

  def with_type_and_default_value(greeting = String | 'Hello')
    greeting
  end

  def with_multiple_types(greeting = String | Integer)
    greeting
  end

  def with_multiple_types_and_default_value(greeting = String | Integer | 'Salutations')
    greeting
  end

  class << self
    def say_goodbye(goodbye = String | 'Goodbye')
      goodbye
    end
  end
end
