module LowType
  class MethodProxy
    attr_reader :name, :params, :return_expression

    def initialize(name:, params: [], return_expression: nil)
      @name = name
      @params = params
      @return_expression = return_expression
    end
  end
end
