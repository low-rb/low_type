# frozen_string_literal: true

require_relative '../../lib/low_type'

LowType.configure { |c| c.type_checking = :rewrite }

class TypeCheckingRewrite
  include LowType

  def typed_arg(greeting = String)
    greeting
  end
end

LowType.configure { |c| c.type_checking = true }
