require_relative '../../lib/low_type.rb'

class LowHello
  include LowType

  def initialize(greeting = String, name: String)
    @greeting = greeting
    @name = name
  end

  def say_hello(greeting = String | 'Hello')
    greeting
  end

  class << self
    def say_goodbye(goodbye = String | 'Goodbye')
      goodbye
    end
  end
end
