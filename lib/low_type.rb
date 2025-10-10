# frozen_string_literal: true

module LowType
  class InvalidTypeError < StandardError; end;
  class RequiredTypeError < StandardError; end;

  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.included(base)
    class << base
      def low_params
        @low_params ||= {}
      end

      def type(var_proxy)
        # TODO: Runtime type expression for the supplied variable.
      end
      alias_method :low_type, :type
    end

    base.prepend LowType.redefine_methods(file_path: LowType.file_path(klass: base), klass: base)
  end

  def self.redefine_methods(file_path:, klass:)
    Module.new do
      # TODO: Use an AST.
      File.readlines(file_path).each do |file_line|
        method_line = file_line.strip
        next unless method_line.start_with?('def ') && method_line.include?('(')

        method_name, args = method_line.delete_prefix('def ').split(/[()]/)
        method_name = method_name.to_sym

        proxy_method = eval("-> (#{args}) {}")
        required_args, required_kwargs = LowType.required_args(proxy_method)

        klass.low_params[method_name] = LowType.type_expressions_from_params(proxy_method, args, required_args, required_kwargs)
        
        define_method(method_name) do |*args, **kwargs|
          klass.low_params[method_name].each do |param_proxy|
            arg = param_proxy.position ? args[param_proxy.position] : kwargs[param_proxy.name]
            arg = param_proxy.type_expression.default_value if arg.nil? && param_proxy.type_expression.default_value != :LOW_TYPE_UNDEFINED
            param_proxy.type_expression.validate!(arg:, name: param_proxy.name)
            param_proxy.position ? args[param_proxy.position] = arg : kwargs[param_proxy.name] = arg
          end

          super(*args, **kwargs)
        end
      end
    end
  end

  class << self
    def methods(klass)
      klass.public_instance_methods(false) + klass.protected_instance_methods(false) + klass.private_instance_methods(false)
    end

    def file_path(klass:)
      caller.find { |callee| callee.end_with?("<class:#{klass}>'") }.split(':').first
    end

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
      if arg.nil? && required?
        raise ::LowType::RequiredTypeError, "Missing value of required type '#{@type}' for '#{name}'"
      end

      raise ::LowType::InvalidTypeError, "Invalid type '#{arg.class}' for '#{name}'" unless arg.class == @type
    end
  end

  class Boolean; end
  class KeyValue; end
end

class Object
  class << self
    # "|" is not defined on Object class and this is the most compute-efficient way to achieve our goal (world peace).
    # "|" bitwise operator on Integer is not called when the receiver is the Integer class (instead of a value like "123").
    def |(default_value)
      type_expression = ::LowType::TypeExpression.new(type: self)
      type_expression | default_value
    end
  end
end
