# frozen_string_literal: true

require_relative '../../lib/low_type'

class Hello
  include LowType

  def initialize(greeting, name)
    @greeting = greeting
    @name = name
  end

  def arg(greeting)
    greeting
  end

  def arg_and_default_value(greeting = 'Hello')
    greeting
  end

  class << self
    def say_goodbye(goodbye)
      goodbye
    end
  end

  private

  def private_arg(greeting)
    greeting
  end
end
