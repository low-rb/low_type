require_relative 'method_proxy'
require_relative 'param_proxy'
require_relative 'parser'
require_relative 'type_expression'

module LowType
  class Redefiner
    class << self
      def redefine_methods(method_nodes:, private_start_line:, klass:)
        Module.new do
          method_nodes.each do |method_node|
            params = Redefiner.params_with_type_expressions(method_node)
            next if params.empty?

            name = method_node.name
            klass.low_methods[name] = MethodProxy.new(name:, params:)

            define_method(name) do |*args, **kwargs|
              klass.low_methods[name].params.each do |param_proxy|
                value = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]
                value = param_proxy.type_expression.default_value if value.nil? && param_proxy.type_expression.default_value != :LOW_TYPE_UNDEFINED
                param_proxy.type_expression.validate!(value:, name: param_proxy.name)
                param_proxy.position ? args[param_proxy.position] = value : kwargs[param_proxy.name] = value
              end
              end

              super(*args, **kwargs)
            end

            if private_start_line && method_node.start_line > private_start_line
              private name
            end
          end
        end
      end

      def params_with_type_expressions(method_node)
        params = method_node.parameters.slice
        proxy_method = eval("-> (#{params}) {}")
        required_args, required_kwargs = Redefiner.required_args(proxy_method)

        typed_method = eval(
          <<~RUBY
            -> (#{params}) {
              param_proxies = []

              proxy_method.parameters.each_with_index do |param, position|
                type, name = param
                position = nil unless [:opt, :req, :rest].include?(type)

                expression = binding.local_variable_get(name)

                if expression.class == TypeExpression
                  param_proxies << ParamProxy.new(type_expression: expression, name:, type:, position:)
                elsif ::LowType.type?(expression)
                  param_proxies << ParamProxy.new(type_expression: TypeExpression.new(type: expression), name:, type:, position:)
                end
              end

              param_proxies
            }
          RUBY
        )

        # Call method with only its required args to evaluate type expressions (which are stored as default values).
        typed_method.call(*required_args, **required_kwargs)

      # TODO: Write spec for this.
      rescue ArgumentError => e
        raise ArgumentError, "Incorrect param syntax"
      end

      def required_args(proxy_method)
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
