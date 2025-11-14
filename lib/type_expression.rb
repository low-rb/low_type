# frozen_string_literal: true

require_relative 'proxies/param_proxy'
require_relative 'queries/type_query'

module LowType
  root_path = File.expand_path(__dir__)
  adapter_paths = Dir.chdir(root_path) { Dir.glob('adapters/*') }.map { |path| File.join(root_path, path) }
  module_paths = %w[instance_types local_types redefiner].map { |path| File.join(root_path, "#{path}.rb") }

  HIDDEN_PATHS = [File.expand_path(__FILE__), *adapter_paths, *module_paths].freeze

  # Represent types and default values as a series of chainable expressions.
  class TypeExpression
    attr_reader :types, :default_value

    # @param type - A literal type or an instance representation of a typed structure.
    def initialize(type: nil, default_value: :LOW_TYPE_UNDEFINED)
      @types = []
      @types << type unless type.nil?
      @default_value = default_value
    end

    def |(expression)
      if expression.instance_of?(::LowType::TypeExpression)
        @types += expression.types
        @default_value = expression.default_value
      elsif ::LowType::TypeQuery.value?(expression)
        @default_value = expression
      else
        @types << expression
      end

      self
    end

    def required?
      @default_value == :LOW_TYPE_UNDEFINED
    end

    def validate!(value:, proxy:) # rubocop:disable Metrics
      if value.nil?
        return true if @default_value.nil?
        raise proxy.error_type, proxy.error_message(value:) if required?
      end

      @types.each do |type|
        # Example: HTML is a subclass of String and should pass as a String.
        return true if LowType::TypeQuery.basic_type?(type:) && type <= value.class
        return true if type.is_a?(::Array) && value.is_a?(::Array) && array_types_match_values?(types: type, values: value)
        return true if type.is_a?(::Hash) && value.is_a?(::Hash) && hash_types_match_values?(type:, value:)
      end

      raise proxy.error_type, proxy.error_message(value:)
    rescue proxy.error_type => e
      raise proxy.error_type, e.message, backtrace_with_proxy(backtrace: e.backtrace, proxy:)
    end

    def valid_types
      types = @types.map do |type|
        # Remove 'LowType::' namespace in subtypes.
        if type.is_a?(::Array)
          "[#{type.map { |subtype| subtype.to_s.delete_prefix('LowType::') }.join(', ')}]"
        else
          type.inspect.to_s.delete_prefix('LowType::')
        end
      end

      types += ['nil'] if @default_value.nil?
      types.join(' | ')
    end

    private

    def array_types_match_values?(types:, values:)
      # [T, T, T]
      if types.length > 1
        types.each_with_index do |type, index|
          # Example: HTML is a subclass of String and should pass as a String.
          return false unless type <= values[index].class
        end
      # [T]
      elsif types.length == 1
        return false unless types.first == values.first.class
      end
      # TODO: Deep type check (all elements for [T]).

      true
    end

    def hash_types_match_values?(type:, value:)
      # TODO: Shallow validation of hash could be made deeper with user config.
      type.keys[0] == value.keys[0].class && type.values[0] == value.values[0].class
    end

    def backtrace_with_proxy(proxy:, backtrace:)
      # Remove LowType defined method file paths from the backtrace.
      filtered_backtrace = backtrace.reject { |line| HIDDEN_PATHS.find { |file_path| line.include?(file_path) } }

      # Add the proxied file to the backtrace.
      proxy_file_backtrace = "#{proxy.file.path}:#{proxy.file.line}:in '#{proxy.file.scope}'"
      from_prefix = filtered_backtrace.first.match(/\s+from /)
      proxy_file_backtrace = "#{from_prefix}#{proxy_file_backtrace}" if from_prefix

      [proxy_file_backtrace, *filtered_backtrace]
    end
  end
end
