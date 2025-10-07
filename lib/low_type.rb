# frozen_string_literal: true

module LowType
  class InvalidType < StandardError; end;

  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.prepended(base)
    class << base
      def low_params
        @low_params ||= {}
      end
    end

    file_path = caller.find { |callee| callee.end_with?("<class:#{base}>'") }.split(':').first

    # TODO: Use an AST.
    File.readlines(file_path).each do |file_line|
      method_line = file_line.strip
      next unless method_line.start_with?('def ') && method_line.include?('(')

      method_name, args = method_line.delete_prefix('def ').split(/[()]/)
      method_name = method_name.to_sym
      method_name = :new if method_name == :initialize # TODO: Override the private initialize method instead.

      proxy_method = eval("-> (#{args}) {}")
      required_args, required_kwargs = LowType.required_args(proxy_method)

      base.low_params[method_name] = LowType.type_expressions_from_params(proxy_method, args, required_args, required_kwargs)
      
      LowType.redefine_method(base, method_name)
    end  
  end

  class << self
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
              elsif expression.respond_to?(:new)
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

    def redefine_method(klass, method_name)
      method_type = :initialize ? :define_singleton_method : :define_method

      klass.send(method_type, method_name) do |*args, **kwargs|
        low_params[method_name].each do |param_proxy|
          arg = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]
          param_proxy.type_expression.validate!(arg:, name: param_proxy.name)
        end

        super(*args, **kwargs)
      end
    end
  end

  class ParamProxy
    attr_reader :type_expression, :name, :type, :position

    def initialize(type_expression:, name:, type:, position: nil)
      @type_expression = type_expression
      @name = name
      @type = type
      @position = position
    end
  end

  class TypeExpression
    attr_reader :type, :default_value

    def initialize(type:)
      @type = type
      @default_value = :LOW_TYPE_UNDEFINED
    end

    def |(default_value)
      @default_value = default_value
      self
    end

    def required?
      @default_value == :LOW_TYPE_UNDEFINED
    end

    def validate!(arg:, name:)
      raise ::LowType::InvalidType, "Invalid type '#{arg.class}' for '#{name}'" unless arg.class == @type
    end
  end

  class Boolean; end
  class KeyValue; end
end

class Object
  class << self
    # "|" is not defined on Object class and this is the most compute-efficient way to achieve our goal (world peace).
    # "|" bitwise operator on Integer is not called when the receiver is the Integer class (instead of an "instance" like "123").
    def |(default_value)
      type_expression = ::LowType::TypeExpression.new(type: self)
      type_expression | default_value
    end
  end
end
