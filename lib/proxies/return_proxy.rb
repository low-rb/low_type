# frozen_string_literal: true

require_relative '../interfaces/error_interface'
require_relative '../error_types'

module LowType
  class ReturnProxy < ErrorInterface
    attr_reader :type_expression, :name

    def initialize(type_expression:, name:, file:)
      @type_expression = type_expression
      @name = name
      @file = file
    end

    def error_type
      ReturnTypeError
    end

    def error_message(value:)
      "Invalid return type '#{value.class}' for method '#{@name}'. Valid types: '#{@type_expression.valid_types}'"
    end
  end
end
