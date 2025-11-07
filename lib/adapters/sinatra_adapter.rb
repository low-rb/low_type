# frozen_string_literal: true

require 'prism'

require_relative '../interfaces/adapter_interface'
require_relative '../proxies/file_proxy'
require_relative '../proxies/return_proxy'
require_relative '../types/error_types'

module LowType
  module Adapter
    # We don't use https://sinatrarb.com/extensions.html because we need to type check all Ruby methods (not just Sinatra) at a lower level.
    class Sinatra < AdapterInterface
      def initialize(klass:, parser:, file_path:)
        @klass = klass
        @parser = parser
        @file_path = file_path
      end

      def process # rubocop:disable Metrics/AbcSize
        method_calls = @parser.method_calls(method_names: %i[get post patch put delete options query])

        # Type check return values.
        method_calls.each do |method_call|
          arguments_node = method_call.compact_child_nodes.first
          next unless arguments_node.is_a?(Prism::ArgumentsNode)

          pattern = arguments_node.arguments.first.content

          line = Parser.line_number(node: method_call)
          file = FileProxy.new(path: @file_path, line:, scope: "#{@klass}##{method_call.name}")
          next unless (return_proxy = return_proxy(method_node: method_call, pattern:, file:))

          route = "#{method_call.name.upcase} #{pattern}"
          params = [ParamProxy.new(type_expression: nil, name: :route, type: :req, position: 0, file:)]
          @klass.low_methods[route] = MethodProxy.new(name: method_call.name, params:, return_proxy:)
        end
      end

      def return_proxy(method_node:, pattern:, file:)
        return_type = Parser.return_type(method_node:)
        return nil if return_type.nil?

        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        expression = eval(return_type.slice).call # rubocop:disable Security/Eval
        expression = TypeExpression.new(type: expression) unless expression.is_a?(TypeExpression)

        ReturnProxy.new(type_expression: expression, name: "#{method_node.name.upcase} #{pattern}", file:)
      end
    end

    module Methods
      # Unfortunately overriding invoke() is the best way to validate types for now. Though direct it's also very compute efficient.
      # I originally tried an after filter and it mostly worked but it only had access to Response which isn't the raw return value.
      # I suggest that Sinatra provide a hook that allows us to access the raw return value of a route before it becomes a Response.
      def invoke(&block)
        res = catch(:halt, &block)

        low_validate!(value: res) if res

        res = [res] if res.is_a?(Integer) || res.is_a?(String)
        if res.is_a?(::Array) && res.first.is_a?(Integer)
          res = res.dup
          status(res.shift)
          body(res.pop)
          headers(*res)
        elsif res.respond_to? :each
          body res
        end

        nil # avoid double setting the same response tuple twice
      end

      def low_validate!(value:)
        route = "#{request.request_method} #{request.path}"
        if (method_proxy = self.class.low_methods[route]) && (proxy = method_proxy.return_proxy)
          proxy.type_expression.validate!(value:, proxy:)
        end
      end
    end
  end
end
