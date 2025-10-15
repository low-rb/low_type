module LowType
  class TypeExpression
    attr_reader :type, :default_value

    def initialize(type:, default_value: :LOW_TYPE_UNDEFINED)
      @types = [type]
      @default_value = default_value
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
      if arg.nil?
        return true if @default_value.nil?
        raise ArgumentError, "Missing required argument of type '#{@types.join(', ')}' for '#{name}'" if required?
      end

      @types.each do |type|
        return true if LowType.type?(type) && type == arg.class 
        # TODO: Shallow validation of enumerables could be made deeper with user config.
        return true if type.class == Array && arg.class == Array && type.first == arg.first.class
        if type.class == Hash && arg.class == Hash && type.keys[0] == arg.keys[0].class && type.values[0] == arg.values[0].class
          return true
        end
      end

      raise TypeError, "Invalid type '#{arg.class}' for '#{name}'"
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
