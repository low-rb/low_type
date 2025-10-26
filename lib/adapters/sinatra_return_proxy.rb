require_relative '../proxies/return_proxy'

module LowType
  class SinatraReturnProxy < ReturnProxy
    attr_reader :type_expression, :name

    def initialize(type_expression:, name:, file:)
      @type_expression = type_expression
      @name = name
      @file = file
    end

    def error_message(value:)
      value = value[0...20] if value
      "Invalid return value '#{value}' for method '#{@name}'. Valid types: '#{@type_expression.valid_types}'"
    end
  end
end
