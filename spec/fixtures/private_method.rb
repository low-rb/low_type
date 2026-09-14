# frozen_string_literal: true

require_relative '../../lib/lowtype'

class PrivateMethod
  include LowType

  private

  def private_typed_arg(greeting = String)
    greeting
  end
end
