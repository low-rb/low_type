# frozen_string_literal: true

require_relative 'adapters/adapter_loader'
require_relative 'basic_types'
require_relative 'instance_types'
require_relative 'local_types'
require_relative 'redefiner'
require_relative 'subclasses'
require_relative 'type_expression'
require_relative 'value_expression'

# Include this module into your class to define and check types.
module LowType
  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.included(klass) # rubocop:disable Metrics/AbcSize
    class << klass
      def low_methods
        @low_methods ||= {}
      end
    end

    file_path = LowType.file_path(klass:)
    parser = LowType::Parser.new(file_path:)
    private_start_line = parser.private_start_line

    klass.extend InstanceTypes
    klass.include LocalTypes
    klass.prepend LowType::Redefiner.redefine(method_nodes: parser.instance_methods, klass:, private_start_line:, file_path:)
    klass.singleton_class.prepend LowType::Redefiner.redefine(method_nodes: parser.class_methods, klass:, private_start_line:, file_path:)

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

    def file_path(klass:)
      # Remove module namespaces from class.
      class_name = klass.to_s.split(':').last
      # The first class found regardless of namespace will be the class that did the include.
      caller.find { |callee| callee.end_with?("<class:#{class_name}>'") }.split(':').first
    end

    # TODO: Unit test.
    def type?(type)
      LowType.basic_type?(type:) || LowType.complex_type?(type:)
    end

    def basic_type?(type:)
      type.respond_to?(:new) || type == Integer || type == Symbol
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
