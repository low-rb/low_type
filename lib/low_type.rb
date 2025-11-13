# frozen_string_literal: true

require_relative 'adapters/adapter_loader'
require_relative 'types/complex_types'
require_relative 'instance_types'
require_relative 'local_types'
require_relative 'redefiner'
require_relative 'syntax'
require_relative 'type_expression'
require_relative 'value_expression'

module LowType
  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.included(klass)
    class << klass
      def low_methods
        @low_methods ||= {}
      end
    end

    file_path = LowType.file_path
    parser = FileParser.new(klass:, file_path:)
    line_numbers = parser.line_numbers

    klass.extend InstanceTypes
    klass.include LocalTypes
    klass.prepend LowType::Redefiner.redefine(method_nodes: parser.instance_methods, klass:, line_numbers:, file_path:)
    klass.singleton_class.prepend LowType::Redefiner.redefine(method_nodes: parser.class_methods, klass:, line_numbers:, file_path:)

    if (adapter = Adapter::Loader.load(klass:, parser:, file_path:))
      adapter.process
      klass.prepend Adapter::Methods
    end
  end

  class << self
    # Public API.

    def config
      config = Struct.new(:deep_type_check, :severity_level)
      @config ||= config.new(false, :error)
    end

    def configure
      yield(config)
    end

    # Internal API.

    def file_path
      includer_file = caller.find { |callee| callee.end_with?("in 'Module#include'") || callee.end_with?("in 'include'") }
      includer_file.split(':').first
    end

    # TODO: Unit test.
    def type?(type)
      LowType.basic_type?(type:) || LowType.complex_type?(type:)
    end

    def basic_type?(type:)
      type.class == Class
    end

    def complex_type?(type:)
      !basic_type?(type:) && LowType.typed_hash?(type:)
    end

    def typed_hash?(type:)
      type.is_a?(::Hash) && LowType.basic_type?(type: type.keys.first) && LowType.basic_type?(type: type.values.first)
    end

    def value?(expression)
      !expression.respond_to?(:new) && expression != Integer
    end

    def value(type:)
      TypeExpression.new(default_value: ValueExpression.new(value: type))
    end
  end
end
