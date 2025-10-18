require_relative 'proxies/local_proxy'
require_relative 'type_expression'
require_relative 'value_expression'

module TypeAssignment
  class AssignmentError < StandardError; end

  def type(type_expression)
    object = type_expression.default_value

    if !LowType.value?(object)
      raise AssignmentError, "Single-instance objects like #{object} are not supported"
    end

    local_proxy = LowType::LocalProxy.new(type_expression:, name: self)
    object.instance_variable_set('@local_proxy', local_proxy)

    type_expression.validate!(value: object, proxy: local_proxy, line: caller_locations(1, 1).first.lineno)

    def object.with_type=(value)
      local_proxy = self.instance_variable_get('@local_proxy')
      type_expression = local_proxy.type_expression
      type_expression.validate!(value:, proxy: local_proxy, line: caller_locations(1, 1).first.lineno)

      # We can't reassign self in Ruby so we reassign instance variables instead.
      value.instance_variables.each do |variable|
        self.instance_variable_set(variable, value.instance_variable_get(variable))
      end

      self
    end

    return object.value if object.is_a?(ValueExpression)

    object
  end
  alias_method :low_type, :type

  def value(type)
    LowType.value(type:)
  end
  alias_method :low_value, :value
end

module LowType
  class Array < ::Array
    def self.[](type)
      return TypeExpression.new(type: [type]) if LowType.type?(type)
      super
    end
  end

  class Hash < ::Hash
    def self.[](type)
      return TypeExpression.new(type:) if LowType.type?(type)
      super
    end
  end
end
