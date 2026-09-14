# frozen_string_literal: true

require_relative '../../lib/lowtype'

class PaymentMethod; end

class Order
  include LowType

  def process(method: PaymentMethod)
    method
  end
end
