# frozen_string_literal: true

require_relative '../expressions/expressions'
require_relative '../expressions/type_expression'
require_relative '../expressions/value_expression'
require_relative '../factories/expression_factory'
require_relative '../factories/proxy_factory'
require_relative '../proxies/file_proxy'
require_relative '../proxies/method_proxy'
require_relative '../proxies/param_proxy'
require_relative '../queries/type_query'
require_relative '../syntax/syntax'
require_relative 'repository'

module LowType
  # Redefine methods to have their arguments and return values type checked.
  class Redefiner
    using Syntax

    class << self
      include Expressions

      def redefine(method_nodes:, class_proxy:, file_path:)
        method_proxies = create_method_proxies(method_nodes:, klass: class_proxy.klass, file_path:)
        define_methods(method_proxies:, class_proxy:)
      end

      def redefinable?(method_proxy:, class_proxy:)
        # Method has no types.
        if method_proxy.params == [] && method_proxy.return_proxy.nil?
          LowType::Repository.delete(name: method_proxy.name, klass: class_proxy.klass)
          return false
        end

        # Method outside class bounds.
        within_bounds = method_proxy.start_line > class_proxy.start_line && method_proxy.end_line <= class_proxy.end_line
        if method_proxy.lines? && class_proxy.lines? && !within_bounds
          LowType::Repository.delete(name: method_proxy.name, klass: class_proxy.klass)
          return false
        end

        true
      end

      private

      def create_method_proxies(method_nodes:, klass:, file_path:)
        method_nodes.each do |name, method_node|
          file = ProxyFactory.file_proxy(path: file_path, node: method_node, scope: "#{klass}##{name}")

          param_proxies = param_proxies(method_node:, file:)
          return_proxy = ProxyFactory.return_proxy(method_node:, file:)
          method_proxy = MethodProxy.new(name:, params: param_proxies, return_proxy:, file:)

          Repository.save(method: method_proxy, klass:)
        end

        Repository.all(klass:)
      end

      def define_methods(method_proxies:, class_proxy:) # rubocop:disable Metrics
        Module.new do
          method_proxies.each do |name, method_proxy|
            next unless LowType::Redefiner.redefinable?(method_proxy:, class_proxy:)

            # NOTE: You are now in the binding of the includer class (`name` is also available here).
            define_method(name) do |*args, **kwargs|
              # Inlined version of Repository.load() for performance increase.
              method_proxy = instance_of?(Class) ? low_methods[name] : self.class.low_methods[name] || Object.low_methods[name]

              method_proxy.params.each do |param_proxy|
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

            private name if class_proxy.private_start_line && method_proxy.start_line > class_proxy.private_start_line
          end
        end
      end

      def param_proxies(method_node:, file:)
        return [] if method_node.parameters.nil?

        params = method_node.parameters.slice
        proxy_method = proxy_method(method_node:)
        required_args, required_kwargs = required_args(proxy_method:)

        # Not a security risk because the code comes from a trusted source; the file that did the include. Does the file trust itself?
        # All local variable names are prefixed with __low_type_ to avoid conflicts with the method parameters.
        typed_method = <<~RUBY
          -> (#{params}, __low_type_proxy_method:, __low_type_file:) {
            __low_type_param_proxies = []

            __low_type_proxy_method.parameters.each_with_index do |__low_type_param, __low_type_position|
              __low_type_type, __low_type_name = __low_type_param
              __low_type_position = nil unless [:opt, :req, :rest].include?(__low_type_type)
              __low_type_expression = binding.local_variable_get(__low_type_name)

              if __low_type_expression.is_a?(TypeExpression)
                __low_type_param_proxies << ParamProxy.new(type_expression: __low_type_expression, name: __low_type_name, type: __low_type_type, position: __low_type_position, file: __low_type_file)
              elsif ::LowType::TypeQuery.type?(__low_type_expression)
                __low_type_param_proxies << ParamProxy.new(type_expression: TypeExpression.new(type: __low_type_expression), name: __low_type_name, type: __low_type_type, position: __low_type_position, file: __low_type_file)
              end
            end

            __low_type_param_proxies
          }
        RUBY

        # Called with only required args (as nil) and optional args omitted, to evaluate type expressions (from default values).
        # Also pass the proxy method and file with appropriate names to avoid conflicts with the method parameters.
        eval(typed_method, binding, __FILE__, __LINE__) # rubocop:disable Security/Eval
          .call(*required_args, **required_kwargs, __low_type_proxy_method: proxy_method, __low_type_file: file)

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
    end
  end
end
