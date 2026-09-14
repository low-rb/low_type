# frozen_string_literal: true

require_relative '../../lib/lowtype'

LowType.configure { |c| c.type_checking = false }

class TypeCheckingDisabled
  include LowType

  def typed_arg(greeting = String)
    greeting
  end
end

LowType.configure { |c| c.type_checking = true }
