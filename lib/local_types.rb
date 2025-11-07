# frozen_string_literal: true

require_relative 'proxies/file_proxy'
require_relative 'proxies/local_proxy'
require_relative 'types/error_types'
require_relative 'type_expression'
require_relative 'value_expression'

module LowType
  module LocalTypes
    def type(type_expression)
      value = type_expression.default_value

      last_caller = caller_locations(1, 1).first
      file = FileProxy.new(path: last_caller.path, line: last_caller.lineno, scope: 'local type')
      proxy = LocalProxy.new(type_expression:, name: self, file:)

      type_expression.validate!(value:, proxy:)

      return value.value if value.is_a?(ValueExpression)

      value
    rescue NoMethodError
      raise ConfigError, "Invalid type expression, likely because you didn't add 'using LowType::Syntax'"
    end
    alias low_type type

    def value(type)
      LowType.value(type:)
    end
    alias low_value value
  end
end
