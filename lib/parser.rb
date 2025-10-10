require_relative 'param_proxy'
require_relative 'type_expression'

module LowType
  class Parser
    class << self
      def redefine_methods(file_path:, klass:)
        Module.new do
          # TODO: Use an AST.
          File.readlines(file_path).each do |file_line|
            method_line = file_line.strip
            next unless method_line.start_with?('def ') && method_line.include?('(')

            method_name, args = method_line.delete_prefix('def ').split(/[()]/)
            method_name = method_name.to_sym

            proxy_method = eval("-> (#{args}) {}")
            required_args, required_kwargs = Parser.required_args(proxy_method)

            klass.low_params[method_name] = Parser.type_expressions_from_params(proxy_method, args, required_args, required_kwargs)
            
            define_method(method_name) do |*args, **kwargs|
              klass.low_params[method_name].each do |param_proxy|
                arg = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]
                arg = param_proxy.type_expression.default_value if arg.nil? && param_proxy.type_expression.default_value != :LOW_TYPE_UNDEFINED
                param_proxy.type_expression.validate!(arg:, name: param_proxy.name)
                param_proxy.position ? args[param_proxy.position] = arg : kwargs[param_proxy.name] = arg
              end

              super(*args, **kwargs)
            end
          end
        end
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

      def type_expressions_from_params(proxy_method, args, required_args, required_kwargs)
        typed_method = eval(
          <<~RUBY
            -> (#{args}) {
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
    end
  end
end
