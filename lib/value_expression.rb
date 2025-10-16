class ValueExpression
  attr_reader :value

  def initialize(value:)
    @value = value
  end

  def class
    @value
  end
end
