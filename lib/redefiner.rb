# frozen_string_literal: true

require_relative 'factories/proxy_factory'
require_relative 'proxies/file_proxy'
require_relative 'proxies/method_proxy'
require_relative 'proxies/param_proxy'
require_relative 'syntax/syntax'
require_relative 'type_expression'

module LowType
  # Redefine methods to have their arguments and return values type checked.
  class Redefiner
    using Syntax

    class << self
      def redefine(method_nodes:, klass:, line_numbers:, file_path:)
        create_proxies(method_nodes:, klass:, file_path:)
        define_methods(method_nodes:, line_numbers:)
      end

      private

      def create_proxies(method_nodes:, klass:, file_path:)
        method_nodes.each do |method_node|
          name = method_node.name
          line = FileParser.line_number(node: method_node)
          file = FileProxy.new(path: file_path, line:, scope: "#{klass}##{name}")
          params = param_proxies(method_node:, file:)
          return_proxy = ProxyFactory.return_proxy(method_node:, file:)

          klass.low_methods[name] = MethodProxy.new(name:, params:, return_proxy:)
        end
      end

      def define_methods(method_nodes:, line_numbers:) # rubocop:disable Metrics
        class_start = line_numbers[:class_start]
        class_end = line_numbers[:class_end]
        private_start = line_numbers[:private_start]

        Module.new do
          method_nodes.each do |method_node|
            method_start = method_node.respond_to?(:start_line) ? method_node.start_line : nil
            method_end = method_node.respond_to?(:end_line) ? method_node.end_line : nil

            if method_start && method_end && class_end
              next unless method_start > class_start && method_end <= class_end
            end

            name = method_node.name

            define_method(name) do |*args, **kwargs|
              method_proxy = instance_of?(Class) ? low_methods[name] : self.class.low_methods[name] || Object.low_methods[name]

              method_proxy.params.each do |param_proxy|
                # Get argument value or default value.
                value = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]
                if value.nil? && param_proxy.type_expression.default_value != :LOW_TYPE_UNDEFINED
                  value = param_proxy.type_expression.default_value
                end

                param_proxy.type_expression.validate!(value:, proxy: param_proxy)
                value = value.value if value.is_a?(ValueExpression)
                param_proxy.position ? args[param_proxy.position] = value : kwargs[param_proxy.name] = value
              end

              if (return_proxy = method_proxy.return_proxy)
                return_value = super(*args, **kwargs)
                return_proxy.type_expression.validate!(value: return_value, proxy: return_proxy)
                return return_value
              end

              super(*args, **kwargs)
            end

            private name if private_start && method_start > private_start
          end
        end
      end

      def param_proxies(method_node:, file:)
        return [] if method_node.parameters.nil?

        params = method_node.parameters.slice
        proxy_method = proxy_method(method_node:)
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

      def proxy_method(method_node:)
        params = method_node.parameters.slice
        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        eval("-> (#{params}) {}", binding, __FILE__, __LINE__) # rubocop:disable Security/Eval
      end

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
