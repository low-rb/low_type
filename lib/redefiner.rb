# frozen_string_literal: true

require_relative 'proxies/file_proxy'
require_relative 'proxies/method_proxy'
require_relative 'proxies/param_proxy'
require_relative 'proxies/return_proxy'
require_relative 'parser'
require_relative 'type_expression'

module LowType
  # Redefine methods to have their arguments and return values type checked.
  class Redefiner
    class << self
      def redefine(method_nodes:, klass:, private_start_line:, file_path:) # rubocop:disable Metrics
        Module.new do
          method_nodes.each do |method_node|
            name = method_node.name
            line = Parser.line_number(node: method_node)
            file = FileProxy.new(path: file_path, line:, scope: "#{klass}##{method_node.name}")
            params = Redefiner.params_with_type_expressions(method_node:, file:)
            return_proxy = Redefiner.return_proxy(method_node:, file:)

            klass.low_methods[name] = MethodProxy.new(name:, params:, return_proxy:)

            define_method(name) do |*args, **kwargs|
              klass.low_methods[name].params.each do |param_proxy|
                # Get argument value or default value.
                value = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]
                if value.nil? && param_proxy.type_expression.default_value != :LOW_TYPE_UNDEFINED
                  value = param_proxy.type_expression.default_value
                end
                # Validate argument type.
                param_proxy.type_expression.validate!(value:, proxy: param_proxy)
                # Handle value(type) special case.
                value = value.value if value.is_a?(ValueExpression)
                # Redefine argument value.
                param_proxy.position ? args[param_proxy.position] = value : kwargs[param_proxy.name] = value
              end

              if return_proxy
                return_value = super(*args, **kwargs)
                return_proxy.type_expression.validate!(value: return_value, proxy: klass.low_methods[name].return_proxy)
                return return_value
              end

              super(*args, **kwargs)
            end

            private name if private_start_line && method_node.start_line > private_start_line
          end
        end
      end

      def params_with_type_expressions(method_node:, file:) # rubocop:disable Metrics/MethodLength
        return [] if method_node.parameters.nil?

        params = method_node.parameters.slice
        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        proxy_method = eval("-> (#{params}) {}", binding, __FILE__, __LINE__) # rubocop:disable Security/Eval
        required_args, required_kwargs = required_args(proxy_method:)

        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        typed_method = <<~RUBY
          -> (#{params}) {
            param_proxies = []

            proxy_method.parameters.each_with_index do |param, position|
              type, name = param
              position = nil unless [:opt, :req, :rest].include?(type)
              expression = binding.local_variable_get(name)

              if expression.is_a?(TypeExpression)
                param_proxies << ParamProxy.new(type_expression: expression, name:, type:, position:, file:)
              elsif ::LowType.type?(expression)
                param_proxies << ParamProxy.new(type_expression: TypeExpression.new(type: expression), name:, type:, position:, file:)
              end
            end

            param_proxies
          }
        RUBY

        # Called with only required args (as nil) and optional args omitted, to evaluate type expressions (stored as default values).
        eval(typed_method, binding, __FILE__, __LINE__).call(*required_args, **required_kwargs) # rubocop:disable Security/Eval

      # TODO: Write spec for this.
      rescue ArgumentError => e
        raise ArgumentError, "Incorrect param syntax: #{e.message}"
      end

      def return_proxy(method_node:, file:)
        return_type = Parser.return_type(method_node:)
        return nil if return_type.nil?

        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        expression = eval(return_type.slice).call # rubocop:disable Security/Eval
        expression = TypeExpression.new(type: expression) unless expression.is_a?(TypeExpression)

        ReturnProxy.new(type_expression: expression, name: method_node.name, file:)
      end

      private

      def required_args(proxy_method:)
        required_args = []
        required_kwargs = {}

        proxy_method.parameters.each do |param|
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

      # Value expressions are eval()'d in the context of this module class (the instance doesn't exist yet) so alias API.
      def value(type)
        LowType.value(type:)
      end
    end
  end
end
