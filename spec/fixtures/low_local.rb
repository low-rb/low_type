# frozen_string_literal: true

require_relative '../../lib/low_type'

class LowLocal
  include LowType
  using LowType::Syntax

  def default_string
    type String | 'Hello'
  end

  def default_method
    type String | fetch_method
  end

  def default_string_again
    type String | (nil_method || 'Hello Again')
  end

  def default_typed_value
    type String | value(String)
  end

  def subtype_array
    type Array[Integer] | [1, 2, 3]
  end

  def invalid_subtype_array
    type Array[Integer] | %w[a b c]
  end

  def array_multiple_subtypes
    type Array[Integer, String, Symbol] | [1, '2', :three]
  end

  def invalid_array_multiple_subtypes
    type Array[Integer, String, Symbol] | [:one, 2, '3']
  end

  private

  def fetch_method
    'Goodbye'
  end

  def nil_method
    nil
  end
end

class LowLocalWithoutRefinements
  include LowType

  def subtype_array
    type Array[Integer] | [1, 2, 3]
  end
end
