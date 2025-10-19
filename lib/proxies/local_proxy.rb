require_relative '../interfaces/error_interface'
require_relative '../error_types'

module LowType
  class LocalProxy < ErrorInterface
    attr_reader :type_expression, :name

    def initialize(type_expression:, name:, file:)
      @type_expression = type_expression
      @name = name
      @file = file
    end

    def error_type
      LocalTypeError
    end

    def error_message(value:)
      "Invalid variable type #{value.class} in '#{@name.class}' on line #{@file.line}. Valid types: '#{@type_expression.valid_types}'"
    end
  end
end
