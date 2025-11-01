# frozen_string_literal: true

require_relative '../../lib/low_type'

class LowReader
  include LowType

  type_reader name: String

  def initialize
    @name = 'Cher'
  end
end

class LowWriter
  include LowType

  type_writer name: String

  def initialize
    @name = 'Cher'
  end
end

class LowAccessor
  include LowType

  type_accessor name: String

  def initialize
    @name = 'Cher'
  end
end
