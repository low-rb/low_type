require_relative '../../lib/low_type.rb'

class LowHello
  include LowType

  def initialize(greeting = String, name = String)
    @greeting = greeting
    @name = name
  end

  def typed_arg(greeting = String)
    greeting
  end

  def typed_arg_and_default_value(greeting = String | 'Hello')
    greeting
  end

  def multiple_typed_args(greeting = String | Integer)
    greeting
  end

  def multiple_typed_args_and_default_value(greeting = String | Integer | 'Salutations')
    greeting
  end

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
