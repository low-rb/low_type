require_relative '../interfaces/proxy_interface'
require_relative '../errors'

module LowType
  class ParamProxy < ProxyInterface
    attr_reader :type_expression, :name, :type, :position

    def initialize(type_expression:, name:, type:, position: nil)
      @type_expression = type_expression
      @name = name
      @type = type
      @position = position
    end

    def error_type(value:)
      return ArgumentError if value.nil?
      ArgumentTypeError
    end

    def error_message(value:, line: nil)
      return "Missing argument for parameter '#{@name}'. Position: #{@position}" if value.nil?

      "Invalid argument type '#{value.class}' for parameter '#{@name}'. Valid types: '#{@type_expression.valid_types}'"
    end
  end
end
