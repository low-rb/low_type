# frozen_string_literal: true

require_relative '../expressions/type_expression'
require_relative '../proxies/file_proxy'
require_relative '../proxies/return_proxy'
require_relative '../queries/file_parser'

module LowType
  class ProxyFactory
    class << self
      def file_proxy(node:, path:, scope:)
        start_line = node.respond_to?(:start_line) ? node.start_line : nil
        end_line = node.respond_to?(:end_line) ? node.end_line : nil

        FileProxy.new(path:, start_line:, end_line:, scope:)
      end

      def return_proxy(method_node:, file:)
        return_type = FileParser.return_type(method_node:)
        return nil if return_type.nil?

        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        begin
          expression = eval(return_type.slice, binding, __FILE__, __LINE__).call # rubocop:disable Security/Eval
        rescue NameError => e
          raise NameError,
                "Unknown return type '#{return_type.slice}' for #{file.scope} at #{file.path}:#{file.start_line}"
        end

        expression = TypeExpression.new(type: expression) unless expression.is_a?(TypeExpression)

        ReturnProxy.new(type_expression: expression, name: method_node.name, file:)
      end
    end
  end
end
