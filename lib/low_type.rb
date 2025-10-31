# frozen_string_literal: true

require_relative 'adapters/adapter_loader'
require_relative 'basic_types'
require_relative 'redefiner'
require_relative 'type_expression'
require_relative 'value_expression'

# Include this module into your class to define and check types.
module LowType
  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.included(klass)
    # Array[] and Hash[] class method returns a type expression only for the duration of this "included" hook.
    array_class_method = Array.method('[]').unbind
    hash_class_method = Hash.method('[]').unbind
    LowType.redefine(hash_class_method:)

    class << klass
      def low_methods
        @low_methods ||= {}
      end
    end

    file_path = LowType.file_path(klass:)
    parser = LowType::Parser.new(file_path:)
    private_start_line = parser.private_start_line

    klass.prepend LowType::Redefiner.redefine(method_nodes: parser.instance_methods, klass:, private_start_line:, file_path:)
    klass.singleton_class.prepend LowType::Redefiner.redefine(method_nodes: parser.class_methods, klass:, private_start_line:, file_path:)

    if (adapter = Adapter::Loader.load(klass:, parser:, file_path:))
      adapter.process
      klass.prepend Adapter::Methods
    end
  ensure
    Array.define_singleton_method('[]', array_class_method)
    Hash.define_singleton_method('[]', hash_class_method)
  end

  class << self
    # Public API.

    def config
      config = Struct.new(:local_types, :deep_type_check)
      @config ||= config.new(false, false)
    end

    def configure
      yield(config)

      return unless config.local_types

      require_relative 'local_types'
      include LocalTypes
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

    # TODO: Unit test.
    def redefine(hash_class_method:)
      Array.define_singleton_method('[]') do |*types|
        TypeExpression.new(type: [*types])
      end

      Hash.define_singleton_method('[]') do |type|
        # Support Pry which uses Hash[].
        unless LowType.type?(type)
          Hash.define_singleton_method('[]', hash_class_method)
          result = Hash[type]
          Hash.method('[]').unbind
          return result
        end

        TypeExpression.new(type:)
      end
    end
  end
end
