# frozen_string_literal: true

require_relative 'redefiner'
require_relative 'type_expression'

module LowType
  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.included(klass)
    class << klass
      def low_params
        @low_params ||= {}
      end

      def type(expression)
        # TODO: Runtime type expression for the supplied variable.
      end
      alias_method :low_type, :type

      def value(expression)
        # TODO: Cancel out a type expression.
      end
      alias_method :low_value, :value
    end

    parser = Parser.new(file_path: LowType.file_path(klass:))
    private_start_line = parser.private_start_line
    klass.prepend LowType::Redefiner.redefine_methods(method_nodes: parser.instance_methods, private_start_line:, klass:)
    klass.singleton_class.prepend LowType::Redefiner.redefine_methods(method_nodes: parser.class_methods, private_start_line:, klass:)
  end

  class << self
    def file_path(klass:)
      caller.find { |callee| callee.end_with?("<class:#{klass}>'") }.split(':').first
    end

    def type?(expression)
      expression.respond_to?(:new) || expression == Integer
    end

    def value?(expression)
      !expression.respond_to?(:new) && expression != Integer
    end
  end

  class ValueExpression; end
  class Boolean; end # TrueClass or FalseClass
  class KeyValue; end # KeyValue[String => Hash]
  class MixedTypes; end # MixedTypes[String | Integer]
end
