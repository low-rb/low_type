require_relative '../../lib/low_type.rb'

class LowHello
  prepend LowType

  def initialize(default_value = nil, casual_greeting = String, generic_name: String)
    @casual_greeting = casual_greeting
    @generic_name = generic_name
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
