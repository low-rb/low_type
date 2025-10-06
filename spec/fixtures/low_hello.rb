require_relative '../../lib/low_type.rb'

class LowHello
  prepend LowType

  def initialize(greeting, name:)
    @greeting = greeting
    @name = name
  end

  def say_hello(greeting = String | 'Hello')
    puts greeting
  end

  class << self
    def say_goodbye(goodbye = String | 'Goodbye')
      puts goodbye
    end
  end
end
