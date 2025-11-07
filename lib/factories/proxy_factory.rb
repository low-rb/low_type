# frozen_string_literal: true

require_relative '../proxies/return_proxy'
require_relative '../file_parser'
require_relative '../type_expression'

module LowType
  class ProxyFactory
    class << self
      def return_proxy(method_node:, file:)
        return_type = FileParser.return_type(method_node:)
        return nil if return_type.nil?

        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        expression = eval(return_type.slice, binding, __FILE__, __LINE__).call # rubocop:disable Security/Eval
        expression = TypeExpression.new(type: expression) unless expression.is_a?(TypeExpression)

        ReturnProxy.new(type_expression: expression, name: method_node.name, file:)
      end
    end
  end
end
