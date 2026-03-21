# frozen_string_literal: true

require_relative '../../lib/low_type'

class BooleanAndEnum
  include LowType

  def boolean_arg(flag: Boolean)
    flag
  end

  def boolean_with_default(flag: Boolean | true)
    flag
  end

  def enum_arg(status: Enum[:draft, :published, :archived])
    status
  end

  def enum_with_default(status: Enum[:draft, :published] | :draft)
    status
  end
end
