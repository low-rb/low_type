require_relative 'type_expression'
require_relative 'value_expression'

module TypeAssignment
  class AssignmentError < StandardError; end

  def type(type_expression)
    object = type_expression.default_value

    if !LowType.value?(object)
      raise AssignmentError, "Single-instance objects like #{object} are not supported"
    end

    object.instance_variable_set('@type_expression', type_expression)

    def object.with_type=(value)
      type_expression = self.instance_variable_get('@type_expression')
      type_expression.validate!(value:, name: self, error_type: TypeError, error_keyword: 'object')

      # We can't re-assign self in Ruby so we re-assign instance variables instead.
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
