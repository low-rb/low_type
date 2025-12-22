# frozen_string_literal: true

require_relative '../expressions/expressions'
require_relative '../expressions/type_expression'
require_relative '../proxies/file_proxy'
require_relative '../proxies/param_proxy'
require_relative '../proxies/return_proxy'
require_relative '../queries/file_parser'
require_relative '../syntax/syntax'

module LowType
  class ProxyFactory
    using ::LowType::Syntax

    class << self
      include Expressions

      def file_proxy(node:, path:, scope:)
        start_line = node.respond_to?(:start_line) ? node.start_line : nil
        end_line = node.respond_to?(:end_line) ? node.end_line : nil

        FileProxy.new(path:, start_line:, end_line:, scope:)
      end

      def param_proxies(method_node:, file:)
        return [] if method_node.parameters.nil?

        params_without_block = method_node.parameters.slice.delete_suffix(', &block')

        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        ruby_method = eval("-> (#{params_without_block}) {}", binding, __FILE__, __LINE__) # rubocop:disable Security/Eval

        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        # Local variable names are prefixed with __lt or __rb where necessary to avoid being overridden by method parameters.
        typed_method = <<~RUBY
          -> (#{params_without_block}, __rb_method:, __lt_file:) {
            param_proxies_for_type_expressions(ruby_method: __rb_method, file: __lt_file, method_binding: binding)
          }
        RUBY

        # Called with only required args (as nil) and optional args omitted, to evaluate type expressions (from default values).
        # Passes internal variables with namespaced names to avoid conflicts with the method parameters.
        required_args, required_kwargs = required_args(ruby_method:)
        eval(typed_method, binding, __FILE__, __LINE__) # rubocop:disable Security/Eval
          .call(*required_args, **required_kwargs, __rb_method: ruby_method, __lt_file: file)

      # TODO: Unit test this.
      rescue ArgumentError => e
        raise ArgumentError, "Incorrect param syntax: #{e.message}"
      end

      def return_proxy(method_node:, file:)
        return_type = FileParser.return_type(method_node:)
        return nil if return_type.nil?

        begin
          # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
          expression = eval(return_type.slice, binding, __FILE__, __LINE__).call # rubocop:disable Security/Eval
        rescue NameError
          raise NameError, "Unknown return type '#{return_type.slice}' for #{file.scope} at #{file.path}:#{file.start_line}"
        end

        expression = TypeExpression.new(type: expression) unless expression.is_a?(TypeExpression)

        ReturnProxy.new(type_expression: expression, name: method_node.name, file:)
      end

      private

      def required_args(ruby_method:)
        required_args = []
        required_kwargs = {}

        ruby_method.parameters.each do |param|
          param_type, param_name = param

          case param_type
          when :req
            required_args << nil
          when :keyreq
            required_kwargs[param_name] = nil
          end
        end

        [required_args, required_kwargs]
      end

      def param_proxies_for_type_expressions(ruby_method:, file:, method_binding:)
        param_proxies = []

        ruby_method.parameters.each_with_index do |param, position|
          type, name = param
          position = nil unless %i[opt req rest].include?(type)
          expression = method_binding.local_variable_get(name)

          type_expression = nil
          if expression.is_a?(TypeExpression)
            type_expression = expression
          elsif ::LowType::TypeQuery.type?(expression)
            type_expression = TypeExpression.new(type: expression)
          end

          param_proxies << ParamProxy.new(type_expression:, name:, type:, position:, file:) if type_expression
        end

        param_proxies
      end
    end
  end
end
