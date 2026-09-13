# frozen_string_literal: true

require_relative '../../lib/low_type'

class Animal; end
class Dog < Animal; end
class GoldenRetriever < Dog; end

class Kennel
  include LowType

  def admit(pet: Animal)
    "Welcome, #{pet.class}!"
  end
end

class NumericStore
  include LowType

  def save(value: Numeric)
    value
  end
end

class IOReader
  include LowType

  def read(source: IO)
    source.class.name
  end
end
