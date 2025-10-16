# frozen_string_literal: true

require_relative 'redefiner'
require_relative 'type_expression'
require_relative 'value_expression'

module LowType
  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.included(klass)

    # Array[] class method returns a type expression only for the duration of this "included" hook.
    array_class_method = Array.method('[]').unbind
    Array.define_singleton_method('[]') do |expression|
      TypeExpression.new(type: [(expression)])
    end

    # Hash[] class method returns a type expression only for the duration of this "included" hook.
    hash_class_method = Hash.method('[]').unbind
    Hash.define_singleton_method('[]') do |expression|
      # Support Pry which uses Hash[].
      unless LowType.type?(expression)
        Hash.define_singleton_method('[]', hash_class_method)
        result = Hash[expression]
        Hash.method('[]').unbind
        return result
      end

      TypeExpression.new(type: expression)
    end

    class << klass
      # Public API.
      def type(expression)
        # TODO: Runtime type expression for the supplied variable.
      end
      alias_method :low_type, :type

      # Public API.
      def value(expression)
        ::LowType.value(expression)
      end
      alias_method :low_value, :value

      # Internal API.
      def low_methods
        @low_methods ||= {}
      end
    end

    parser = Parser.new(file_path: LowType.file_path(klass:))
    private_start_line = parser.private_start_line

    klass.prepend LowType::Redefiner.redefine_methods(method_nodes: parser.instance_methods, private_start_line:, klass:)
    klass.singleton_class.prepend LowType::Redefiner.redefine_methods(method_nodes: parser.class_methods, private_start_line:, klass:)
  ensure
    Array.define_singleton_method('[]', array_class_method)
    Hash.define_singleton_method('[]', hash_class_method)
  end

  # Internal API.
  class << self
    def file_path(klass:)
      caller.find { |callee| callee.end_with?("<class:#{klass}>'") }.split(':').first
    end

    def type?(expression)
      expression.respond_to?(:new) || expression == Integer || (expression.is_a?(Hash) && expression.keys.first.respond_to?(:new) && expression.values.first.respond_to?(:new))
    end

    def value?(expression)
      !expression.respond_to?(:new) && expression != Integer
    end

    def value(type)
      TypeExpression.new(default_value: ValueExpression.new(value: type))
    end
  end

  class Boolean; end # TrueClass or FalseClass
end
