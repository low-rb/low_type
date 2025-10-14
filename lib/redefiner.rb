require_relative 'param_proxy'
require_relative 'parser'
require_relative 'type_expression'

module LowType
  class Redefiner
    class << self
      def redefine_methods(method_nodes:, private_start_line:, klass:)
        Module.new do
          method_nodes.each do |method_node|
            klass.low_params[method_node.name] = Redefiner.param_proxy_with_type_expressions(method_node)
            next if klass.low_params[method_node.name].empty?

            define_method(method_node.name) do |*args, **kwargs|
              klass.low_params[method_node.name].each do |param_proxy|
                arg = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]
                arg = param_proxy.type_expression.default_value if arg.nil? && param_proxy.type_expression.default_value != :LOW_TYPE_UNDEFINED
                param_proxy.type_expression.validate!(arg:, name: param_proxy.name)
                param_proxy.position ? args[param_proxy.position] = arg : kwargs[param_proxy.name] = arg
              end

              super(*args, **kwargs)
            end

            if private_start_line && method_node.start_line > private_start_line
              private method_node.name
            end
          end
        end
      end

      def param_proxy_with_type_expressions(method_node)
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
