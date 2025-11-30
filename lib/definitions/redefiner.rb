# frozen_string_literal: true

require_relative '../expressions/value_expression'
require_relative '../factories/proxy_factory'
require_relative '../proxies/method_proxy'
require_relative '../queries/type_query'
require_relative 'repository'

module LowType
  # Redefine methods to have their arguments and return values type checked.
  class Redefiner
    class << self
      def redefine(method_nodes:, class_proxy:, file_path:)
        method_proxies = build_methods(method_nodes:, klass: class_proxy.klass, file_path:)

        if LowType.config.type_checking
          typed_methods(method_proxies:, class_proxy:)
        else
          untyped_methods(method_proxies:, class_proxy:)
        end
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

      def untyped_args(args:, kwargs:, method_proxy:) # rubocop:disable Metrics/AbcSize
        method_proxy.params.each do |param_proxy|
          value = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]

          next unless value.nil?
          raise param_proxy.error_type, param_proxy.error_message(value:) if param_proxy.required?

          value = param_proxy.type_expression.default_value # Default value can still be `nil`.
          value = value.value if value.is_a?(ValueExpression)
          param_proxy.position ? args[param_proxy.position] = value : kwargs[param_proxy.name] = value
        end

        [args, kwargs]
      end

      private

      def build_methods(method_nodes:, klass:, file_path:)
        method_nodes.each do |name, method_node|
          file = ProxyFactory.file_proxy(path: file_path, node: method_node, scope: "#{klass}##{name}")

          param_proxies = ProxyFactory.param_proxies(method_node:, file:)
          return_proxy = ProxyFactory.return_proxy(method_node:, file:)
          method_proxy = MethodProxy.new(name:, params: param_proxies, return_proxy:, file:)

          Repository.save(method: method_proxy, klass:)
        end

        Repository.all(klass:)
      end

      def typed_methods(method_proxies:, class_proxy:) # rubocop:disable Metrics
        Module.new do
          method_proxies.each do |name, method_proxy|
            next unless LowType::Redefiner.redefinable?(method_proxy:, class_proxy:)

            # You are now in the binding of the includer class (`name` is also available here).
            define_method(name) do |*args, **kwargs|
              # Inlined version of Repository.load() for performance increase.
              method_proxy = instance_of?(Class) ? low_methods[name] : self.class.low_methods[name] || Object.low_methods[name]

              method_proxy.params.each do |param_proxy|
                value = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]
                value = param_proxy.type_expression.default_value if value.nil? && !param_proxy.required?

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

      def untyped_methods(method_proxies:, class_proxy:)
        Module.new do
          method_proxies.each do |name, method_proxy|
            next unless LowType::Redefiner.redefinable?(method_proxy:, class_proxy:)

            # You are now in the binding of the includer class (`name` is also available here).
            define_method(name) do |*args, **kwargs|
              # NOTE: Type checking is currently disabled. See 'config.type_checking'.
              method_proxy = instance_of?(Class) ? low_methods[name] : self.class.low_methods[name] || Object.low_methods[name]
              args, kwargs = LowType::Redefiner.untyped_args(args:, kwargs:, method_proxy:)
              super(*args, **kwargs)
            end

            private name if class_proxy.private_start_line && method_proxy.start_line > class_proxy.private_start_line
          end
        end
      end
    end
  end
end
