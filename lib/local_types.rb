require_relative 'proxies/file_proxy'
require_relative 'proxies/local_proxy'
require_relative 'type_expression'
require_relative 'value_expression'

module LocalTypes
  class AssignmentError < StandardError; end

  def type(type_expression)
    referenced_object = type_expression.default_value

    if !LowType.value?(referenced_object)
      raise AssignmentError, "Single-instance objects like #{referenced_object} are not supported"
    end

    last_caller = caller_locations(1, 1).first
    file = LowType::FileProxy.new(path: last_caller.path, line: last_caller.lineno, scope: 'local type')
    local_proxy = LowType::LocalProxy.new(type_expression:, name: self, file:)
    referenced_object.instance_variable_set('@local_proxy', local_proxy)

    type_expression.validate!(value: referenced_object, proxy: local_proxy)

    def referenced_object.with_type=(value)
      local_proxy = self.instance_variable_get('@local_proxy')
      type_expression = local_proxy.type_expression
      type_expression.validate!(value:, proxy: local_proxy)

      # We can't reassign self in Ruby so we reassign instance variables instead.
      value.instance_variables.each do |variable|
        self.instance_variable_set(variable, value.instance_variable_get(variable))
      end

      self
    end

    return referenced_object.value if referenced_object.is_a?(ValueExpression)

    referenced_object
  end
  alias_method :low_type, :type

  def value(type)
    LowType.value(type:)
  end
  alias_method :low_value, :value

  # Scoped to the class that includes LowTypes module.
  class Array < ::Array
    def self.[](*types)
      if types.all? { |type| LowType.type?(type) }
        return LowType::TypeExpression.new(type: [*types])
      end

      super
    end
  end

  # Scoped to the class that includes LowTypes module.
  class Hash < ::Hash
    def self.[](type)
      return LowType::TypeExpression.new(type:) if LowType.type?(type)
      super
    end
  end
end
