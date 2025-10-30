# frozen_string_literal: true

require 'prism'

require_relative '../interfaces/adapter_interface'
require_relative '../proxies/file_proxy'
require_relative '../proxies/return_proxy'
require_relative '../error_types'

module LowType
  # We don't use https://sinatrarb.com/extensions.html because we need to type check all Ruby methods (not just Sinatra) at a lower level.
  class SinatraAdapter < AdapterInterface
    def initialize(klass:, parser:, file_path:)
      @klass = klass
      @parser = parser
      @file_path = file_path
    end

    def process
      method_calls = @parser.method_calls(method_names: %i[get post patch put delete options query])

      # Type check return values.
      method_calls.each do |method_call|
        arguments_node = method_call.compact_child_nodes.first
        next unless arguments_node.is_a?(Prism::ArgumentsNode)

        pattern = arguments_node.arguments.first.content

        line = method_call.respond_to?(:start_line) ? method_call.start_line : nil
        file = FileProxy.new(path: @file_path, line:, scope: "#{@klass}##{method_call.name}")
        params = [ParamProxy.new(type_expression: nil, name: :route, type: :req, position: 0, file:)]
        return_proxy = return_proxy(method_node: method_call, pattern:, file:)
        next unless return_proxy

        route = "#{method_call.name.upcase} #{pattern}"
        @klass.low_methods[route] = MethodProxy.new(name: method_call.name, params:, return_proxy:)
      end
    end

    def redefine
      Module.new do
        def invoke(&block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          res = catch(:halt, &block)

          raise AllowedTypeError, 'Did you mean "Response.finish"?' if res.to_s == 'Response'

          route = "#{request.request_method} #{request.path}"
          if res && (method_proxy = self.class.low_methods[route]) && (proxy = method_proxy.return_proxy)
            proxy.type_expression.types.each { |_type| proxy.type_expression.validate!(value: res, proxy:) }
          end

          res = [res] if res.is_a?(Integer) || res.is_a?(String)
          if res.is_a?(Array) && res.first.is_a?(Integer)
            res = res.dup
            status(res.shift)
            body(res.pop)
            headers(*res)
          elsif res.respond_to? :each
            body res
          end

          nil # avoid double setting the same response tuple twice
        end
      end
    end

    private

    def return_proxy(method_node:, pattern:, file:)
      return_type = Parser.return_type(method_node:)
      return nil if return_type.nil?

      # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
      expression = eval(return_type.slice).call # rubocop:disable Security/Eval
      expression = TypeExpression.new(type: expression) unless expression.is_a?(TypeExpression)

      ReturnProxy.new(type_expression: expression, name: "#{method_node.name.upcase} #{pattern}", file:)
    end
  end
end
