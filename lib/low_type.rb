# frozen_string_literal: true

require_relative 'adapters/adapter_loader'
require_relative 'expressions/expressions'
require_relative 'syntax/syntax'
require_relative 'types/complex_types'
require_relative 'queries/file_parser'
require_relative 'queries/file_query'
require_relative 'instance_types'
require_relative 'redefiner'

module LowType
  # We do as much as possible on class load rather than on instantiation to be thread-safe and efficient.
  def self.included(klass)
    require_relative 'syntax/union_types' if LowType.config.union_type_expressions

    class << klass
      def low_methods
        @low_methods ||= {}
      end
    end

    file_path = FileQuery.file_path(klass:)
    parser = FileParser.new(klass:, file_path:)
    line_numbers = parser.line_numbers

    klass.extend InstanceTypes
    klass.include Expressions
    klass.prepend Redefiner.redefine(method_nodes: parser.instance_methods, klass:, line_numbers:, file_path:)
    klass.singleton_class.prepend Redefiner.redefine(method_nodes: parser.class_methods, klass:, line_numbers:, file_path:)

    if (adapter = Adapter::Loader.load(klass:, parser:, file_path:))
      adapter.process
      klass.prepend Adapter::Methods
    end
  end

  class << self
    def config
      config = Struct.new(:error_mode, :output_mode, :output_size, :deep_type_check, :union_type_expressions)
      @config ||= config.new(:error, :type, 100, false, true)
    end

    def configure
      yield(config)
    end
  end
end
