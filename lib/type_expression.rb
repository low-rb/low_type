module LowType
  class TypeExpression
    attr_reader :type, :default_value

    def initialize(type:)
      @types = [type]
      @default_value = :LOW_TYPE_UNDEFINED
    end

    def |(expression)
      if expression.class == ::LowType::TypeExpression
        @types = @types + expression.types
        @default_value = expression.default_value
      elsif ::LowType.value?(expression)
        @default_value = expression
      else
        @types << expression
      end

      self
    end

    def required?
      @default_value == :LOW_TYPE_UNDEFINED
    end

    def validate!(arg:, name:)
      if arg.nil? && required?
        raise ::LowType::RequiredArgError, "Missing value of required type [#{@types.join(',')}] for '#{name}'"
      end

      raise ::LowType::InvalidTypeError, "Invalid type '#{arg.class}' for '#{name}'" unless @types.include?(arg.class)
    end
  end
end

class Object
  class << self
    # "|" is not defined on Object class and this is the most compute-efficient way to achieve our goal (world peace).
    # "|" bitwise operator on Integer is not defined when the receiver is an Integer class, so we are not in conflict.
    def |(expression)
      if expression.class == ::LowType::TypeExpression
        expression | self
        expression
      else
        type_expression = ::LowType::TypeExpression.new(type: self)
        type_expression | expression        
      end
    end
  end
end
