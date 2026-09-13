# frozen_string_literal: true

require_relative '../expressions/type_expression'
require_relative '../proxies/return_proxy'
require_relative '../queries/type_query'

module Low
  # Usage:
  #
  # type_accessor name: String # => @name getter and @name=() setter
  # type_accessor name: String | 'Cher'
  #
  # type_reader name: String
  # type_reader name: String | 'Cher' # defaults to 'Cher' if nil
  #
  # type_writer name: String
  # type_writer name: String | nil # accepts String or nil
  #
  module TypeAccessors
    def type_reader(named_expressions)
      named_expressions.each do |name, exp|
        last_caller = caller_locations(1, 1).first

        file_path = last_caller.path
        scope = "#{self}##{name}"

        expression = cast_type_expression(exp)
        # Source usually defined on file load with access to lines in a source file, but type accessors are defined on class load.
        source = ::Lowkey::Source.new(file_path:, scope:, lines: [], start_line: last_caller.lineno, end_line: last_caller.lineno)
        proxy = ::Lowkey::ReturnProxy.new(name:, source:, expression:)

        define_method(name) do
          value = instance_variable_get("@#{name}")
          expression.validate!(value:, proxy:)
          value
        end
      end
    end

    def type_writer(named_expressions)
      named_expressions.each do |name, expression|
        last_caller = caller_locations(1, 1).first

        file_path = last_caller.path
        scope = "#{self}##{name}"

        expression = cast_type_expression(expression)
        # Source usually defined on file load with access to lines in a source file, but type accessors are defined on class load.
        source = ::Lowkey::Source.new(file_path:, scope:, lines: [], start_line: last_caller.lineno, end_line: last_caller.lineno)
        proxy = ::Lowkey::ParamProxy.new(name:, source:, type: :pos_req, position: nil, expression:)

        define_method("#{name}=") do |value|
          expression.validate!(value:, proxy:)
          instance_variable_set("@#{name}", value)
        end
      end
    end

    def type_accessor(named_expressions)
      named_expressions.each do |name, expression|
        type_reader({ name => expression })
        type_writer({ name => expression })
      end
    end

    private

    def cast_type_expression(expression)
      if expression.is_a?(::Expressions::Expression)
        expression
      elsif TypeQuery.type?(expression)
        TypeExpression.new(type: expression)
      end
    end
  end
end
