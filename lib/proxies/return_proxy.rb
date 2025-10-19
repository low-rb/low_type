require_relative '../interfaces/error_interface'
require_relative '../errors'

module LowType
  class ReturnProxy < ErrorInterface
    attr_reader :type_expression, :name

    def initialize(type_expression:, name:)
      @type_expression = type_expression
      @name = name
    end

    def error_type
      ReturnTypeError
    end

    def error_message(value:, line: nil)
      "Invalid return type '#{value.class}' for method '#{@name}'. Valid types: '#{@type_expression.valid_types}'"
    end
  end
end
