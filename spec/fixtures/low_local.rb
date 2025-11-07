# frozen_string_literal: true

require_relative '../../lib/low_type'

class MyType
  attr_reader :id

  def initialize(id:)
    @id = id
  end
end

class LowLocal
  include LowType
  using LowType::Syntax

  attr_reader :typed_array, :typed_default_value, :typed_instance_variable

  def initialize
    @typed_array = nil
    @typed_default_value = nil
    @typed_instance_variable = nil
  end

  def local_type_array
    @typed_array = type Array[Integer] | [1, 2, 3]
  end

  def invalid_local_type_array
    @typed_array = type Array[Integer] | %w[a b c]
  end

  def array_multiple_subtypes
    @typed_array = type Array[Integer, String, Symbol] | [1, '2', :three]
  end

  def invalid_array_multiple_subtypes
    @typed_array = type Array[Integer, String, Symbol] | [:one, 2, '3']
  end

  def local_type_default_value
    @typed_default_value = type String | value(String)
  end

  def local_type_instance_variable
    @typed_instance_variable = type MyType | MyType.new(id: 'assigned')
  end
end

class LowLocalWithoutSyntax
  include LowType

  def local_type_array
    type Array[Integer] | [1, 2, 3]
  end
end
