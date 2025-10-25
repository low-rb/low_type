require_relative 'proxies/param_proxy'

module LowType
  class TypeExpression
    FILE_PATH = File.expand_path(__FILE__)

    attr_reader :types, :default_value

    def initialize(type: nil, default_value: :LOW_TYPE_UNDEFINED)
      @types = []
      @types << type unless type.nil?
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

    # Called in situations where we want to be inclusive rather than exclusive and pass validation if one of the types is valid.
    def validate(value:, proxy:)
      if value.nil?
        return true if @default_value.nil?
        return false if required?
      end

      @types.each do |type|
        return true if LowType.type?(type) && type <= value.class # Example: HTML is a subclass of String and should pass as a String.

        # TODO: Shallow validation of enumerables could be made deeper with user config.
        return true if type.class == ::Array && value.class == ::Array && type.first == value.first.class
        if type.class == ::Hash && value.class == ::Hash && type.keys[0] == value.keys[0].class && type.values[0] == value.values[0].class
          return true
        end
      end

      false
    end

    def validate!(value:, proxy:)
      if value.nil?
        return true if @default_value.nil?
        raise proxy.error_type, proxy.error_message(value:) if required?
      end

      @types.each do |type|
        return true if LowType.type?(type) && type == value.class 
        return true if type.class == ::Array && value.class == ::Array && array_types_match_values?(types: type, values: value)

        # TODO: Shallow validation of hash could be made deeper with user config.
        if type.class == ::Hash && value.class == ::Hash && type.keys[0] == value.keys[0].class && type.values[0] == value.values[0].class
          return true
        end
      end

      raise proxy.error_type, proxy.error_message(value:)
    rescue proxy.error_type => e
      file_paths = [FILE_PATH, LowType::Redefiner::FILE_PATH]
      raise proxy.error_type, e.message, backtrace_with_proxy(file_paths:, backtrace: e.backtrace, proxy:)
    end

    def valid_types
      types = @types.map { |type| type.inspect.to_s }
      types = types + ['nil'] if @default_value.nil?
      types.join(' | ')
    end

    private

    def array_types_match_values?(types:, values:)
      # TODO: Probably better to use an each that breaks early when types run out.
      types.zip(values) do |type, value|
        return false unless type === value
      end

      true
    end

    def backtrace_with_proxy(file_paths:, proxy:, backtrace:)
      # Remove LowType file paths from the backtrace.
      filtered_backtrace = backtrace.reject { |line| file_paths.find { |file_path| line.include?(file_path) } }

      # Add the proxied file to the backtrace.
      proxy_file_backtrace = "#{proxy.file.path}:#{proxy.file.line}:in '#{proxy.file.scope}'"
      from_prefix = filtered_backtrace.first.match(/\s+from /)
      proxy_file_backtrace = "#{from_prefix}#{proxy_file_backtrace}" if from_prefix

      [proxy_file_backtrace, *filtered_backtrace]
    end
  end
end

class Object
  class << self
    # For "Type | [type_expression/type/value]" situations, redirecting to or generating a type expression from types.
    # "|" is not defined on Object class and this is the most compute-efficient way to achieve our goal (world peace).
    # "|" is overridable by any child object. While we could def/undef this method, this approach is actually lighter.
    # "|" bitwise operator on Integer is not defined when the receiver is an Integer class, so we are not in conflict.
    def |(expression)
      if expression.class == ::LowType::TypeExpression
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
