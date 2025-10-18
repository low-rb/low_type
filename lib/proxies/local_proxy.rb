require_relative '../interfaces/proxy_interface'
require_relative '../errors'

module LowType
  class LocalProxy < ProxyInterface
    attr_reader :type_expression, :name

    def initialize(type_expression:, name:)
      @type_expression = type_expression
      @name = name
    end

    def error_type(value:)
      LocalTypeError
    end

    def error_message(value:, line:)
      "Invalid variable type #{value.class} in '#{@name.class}' on line #{line}. Valid types: '#{@type_expression.valid_types.join(', ')}'"
    end
  end
end
