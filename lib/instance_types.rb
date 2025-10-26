require_relative 'proxies/return_proxy'
require_relative 'type_expression'

module InstanceTypes
  def type_reader(named_expressions)
    named_expressions.keys.zip(named_expressions.values) do |name, expression|
      type_expression = type_expression(expression)

      last_caller = caller_locations(1, 1).first
      file = FileProxy.new(path: last_caller.path, line: last_caller.lineno, scope: "#{self}##{name}")
      return_proxy = ReturnProxy.new(type_expression:, name:, file:)

      @low_methods[name] = MethodProxy.new(name:, params:, return_proxy:)

      define_method(name) do
        method_proxy = @low_methods[name]
        value = instance_variable_get(name)
  
        type_expression.validate!(value:, proxy: method_proxy.return_proxy)

        value
      end
    end
  end

  def type_writer(name, type_expression)
    define_method(name) do
    end
  end

  def type_accessor(name, type_expression)
    define_method(name) do
    end
  end

  private

  def type_expression(expression)
    if expression.class == TypeExpression
      param_proxies << ParamProxy.new(type_expression: expression, name:, type:, position:, file:)
    elsif ::LowType.type?(expression)
      param_proxies << ParamProxy.new(type_expression: TypeExpression.new(type: expression), name:, type:, position:, file:)
    end
  end
end
