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
      def low_methods
        @low_methods ||= {}
      end
    end

    file_path = LowType.file_path(klass:)
    parser = Parser.new(file_path:)
    private_start_line = parser.private_start_line

    klass.prepend LowType::Redefiner.redefine_methods(method_nodes: parser.instance_methods, klass:, private_start_line:, file_path:)
    klass.singleton_class.prepend LowType::Redefiner.redefine_methods(method_nodes: parser.class_methods, klass:, private_start_line:, file_path:)
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

      if config.local_types
        require_relative 'local_types'
        include LocalTypes
      end
    end
  
    # Internal API.

    def file_path(klass:)
      # Remove module namespaces from class.
      class_name = klass.to_s.split(':').last
      # The first class found regardless of namespace will be the class that did the include.
      caller.find { |callee| callee.end_with?("<class:#{class_name}>'") }.split(':').first
    end

    def type?(type)
      type.respond_to?(:new) || type == Integer || (type.is_a?(::Hash) && type.keys.first.respond_to?(:new) && type.values.first.respond_to?(:new))
    end

    def value?(expression)
      !expression.respond_to?(:new) && expression != Integer
    end

    def value(type:)
      TypeExpression.new(default_value: ValueExpression.new(value: type))
    end
  end

  class Boolean; end # TrueClass or FalseClass
end
