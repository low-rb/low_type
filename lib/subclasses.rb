module LowType
  # Scoped to the class that includes LowType module.
  class Array < ::Array
    def self.[](*types)
      return LowType::TypeExpression.new(type: [*types]) if types.all? { |type| LowType.type?(type) }
      super
    end

    def self.===(other)
      return true if other == ::Array
      super
    end

    def ==(other)
      return true if other.class == ::Array
      super
    end
  end

  # Scoped to the class that includes LowType module.
  class Hash < ::Hash
    def self.[](type)
      return LowType::TypeExpression.new(type:) if LowType.type?(type)
      super
    end

    def self.===(other)
      return true if other == ::Hash
      super
    end

    def ==(other)
      return true if other.class == ::Hash
      super
    end
  end
end

# Scoped to the top-level for method type expressions to work. Could we bind/unbind? Yes. Should we? Probably not.
class Object
  # For "Type | [type_expression/type/value]" situations, redirecting to or generating a type expression from types.
  # "|" is not defined on Object class and this is the most compute-efficient way to achieve our goal (world peace).
  # "|" is overridable by any child object. While we could def/undef this method, this approach is actually lighter.
  # "|" bitwise operator on Integer is not defined when the receiver is an Integer class, so we are not in conflict.
  class << self
    def |(expression)
      if expression.instance_of?(::LowType::TypeExpression)
        # We pass our type into their type expression.
        expression | self
        expression
      else
        # We turn our type into a type expression and pass in their [type_expression/type/value].
        type_expression = ::LowType::TypeExpression.new(type: self)
        type_expression | expression
      end
    end
  end
end
