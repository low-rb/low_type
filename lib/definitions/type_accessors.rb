# frozen_string_literal: true

require_relative '../expressions/type_expression'
require_relative '../proxies/return_proxy'
require_relative '../queries/type_query'

module LowType
  module TypeAccessors
    def type_reader(named_expressions)
      named_expressions.each do |name, expression|
        last_caller = caller_locations(1, 1).first
        type_expression = type_expression(expression)
        file = FileProxy.new(path: last_caller.path, start_line: last_caller.lineno, scope: "#{self}##{name}")

        @low_methods[name] = MethodProxy.new(name:, return_proxy: ReturnProxy.new(type_expression:, name:, file:))

        define_method(name) do
          method_proxy = self.class.low_methods[name]
          value = instance_variable_get("@#{name}")
          type_expression.validate!(value:, proxy: method_proxy.return_proxy)
          value
        end
      end
    end

    def type_writer(named_expressions)
      named_expressions.each do |name, expression|
        last_caller = caller_locations(1, 1).first
        type_expression = type_expression(expression)
        file = FileProxy.new(path: last_caller.path, start_line: last_caller.lineno, scope: "#{self}##{name}")

        @low_methods["#{name}="] = MethodProxy.new(name:, params: [ParamProxy.new(type_expression:, name:, type: :hashreq, file:)])

        define_method("#{name}=") do |value|
          method_proxy = self.class.low_methods["#{name}="]
          type_expression.validate!(value:, proxy: method_proxy.params.first)
          instance_variable_set("@#{name}", value)
        end
      end
    end

    def type_accessor(named_expressions)
      named_expressions.each do |name, expression|
        type_reader({ name => expression })
        type_writer({ name => expression })
      end
    end

    private

    def type_expression(expression)
      if expression.instance_of?(TypeExpression)
        expression
      elsif ::LowType::TypeQuery.type?(expression)
        TypeExpression.new(type: expression)
      end
    end
  end
end
