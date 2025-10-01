require_relative '../../lib/low_type.rb'

class LowHello
  def initialize(greeting = String | 'Hello')
    @greeting = greeting
  end

  def say_hello(greeting = String | 'Hello')
    puts greeting
  end

  class << self
    def say_goodbye(goodbye = String | 'Goodbye')
      puts goodbye
    end
  end

  include LowType
end
