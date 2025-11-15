# frozen_string_literal: true

require_relative '../factories/type_factory'

module LowType
  COMPLEX_TYPES = [
    Boolean = TypeFactory.complex_type(Object),
    Headers = TypeFactory.complex_type(Hash),
    HTML = TypeFactory.complex_type(String),
    JSON = TypeFactory.complex_type(String),
    Status = TypeFactory.complex_type(Integer),
    Tuple = TypeFactory.complex_type(Array),
    XML = TypeFactory.complex_type(String)
  ].freeze
end
