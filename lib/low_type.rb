# frozen_string_literal: true

require_relative 'parser'
require_relative 'type_expression'

module LowType
  class InvalidTypeError < StandardError; end;
  class RequiredArgError < StandardError; end;

  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.included(base)
    class << base
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

    base.prepend LowType::Parser.redefine_methods(file_path: LowType.file_path(klass: base), klass: base)
  end

  class << self
    def methods(klass)
      klass.public_instance_methods(false) + klass.protected_instance_methods(false) + klass.private_instance_methods(false)
    end

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
  class Boolean; end
  class KeyValue; end
end
