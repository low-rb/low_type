require_relative '../../lib/low_type.rb'

class LowHello
  include LowType

  def initialize(greeting = String, name: String)
    @greeting = greeting
    @name = name
  end

  def typed_arg(greeting = String)
    greeting
  end

  def typed_kwarg(greeting: String)
    greeting
  end

  def typed_arg_and_default_value(greeting = String | 'Hello')
    greeting
  end

  def typed_kwarg_and_default_value(greeting: String | 'Hello')
    greeting
  end

  def multiple_typed_args(greeting = String | Integer)
    greeting
  end

  def multiple_typed_kwargs(greeting: String | Integer)
    greeting
  end

  def multiple_typed_args_and_default_value(greeting = String | Integer | 'Salutations')
    greeting
  end

  def multiple_typed_kwargs_and_default_value(greeting: String | Integer | 'Salutations')
    greeting
  end

  class << self
    def say_goodbye(goodbye = String | 'Goodbye')
      goodbye
    end
  end
end
