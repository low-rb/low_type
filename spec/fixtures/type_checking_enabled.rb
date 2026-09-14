# frozen_string_literal: true

require_relative '../../lib/lowtype'

class TypeCheckingEnabled
  include LowType

  def typed_arg(greeting = String)
    greeting
  end
end
