module LowType
  class ParamProxy
    attr_reader :type_expression, :name, :type, :position

    def initialize(type_expression:, name:, type:, position: nil)
      @type_expression = type_expression
      @name = name
      @type = type
      @position = position
    end
  end
end
