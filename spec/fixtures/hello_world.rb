class Test
  include LowType

  def initialize(greeting = String | 'Hello')
    @greeting = greeting
  end

  def say_hello(greeting = String | 'Hello')
    puts greeting
  end
end
