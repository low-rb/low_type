# frozen_string_literal: true

require_relative '../interfaces/error_interface'
require_relative '../error_types'

module LowType
  class ParamProxy < ErrorInterface
    attr_reader :type_expression, :name, :type, :position

    def initialize(type_expression:, name:, type:, file:, position: nil)
      @type_expression = type_expression
      @name = name
      @type = type
      @position = position
      @file = file
    end

    def error_type
      ArgumentTypeError
    end

    def error_message(value:)
      "Invalid argument type '#{value.class}' for parameter '#{@name}'. Valid types: '#{@type_expression.valid_types}'"
    end
  end
end
