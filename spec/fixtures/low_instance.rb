require_relative '../../lib/low_type.rb'

class LowInstance
  include LowType

  type_reader name: String

  def initialize
    @name = 'Cher'
  end
end
