# frozen_string_literal: true

require_relative '../../lib/low_type'

LowType.configure { |c| c.type_checking = false }

class RewriterFixture
  include LowType

  # Required positional
  def positional_required(name = String)
    name
  end

  # Optional positional with default value
  def positional_with_default(count = Integer | value(0))
    count
  end

  # Required keyword
  def keyword_required(name: String)
    name
  end

  # Optional keyword with default value
  def keyword_with_default(greeting: String | value('Hello'))
    greeting
  end

  # No params
  def no_params
    'ok'
  end

  # Class method
  def self.class_method(label = String)
    label
  end

  private

  # Private method
  def private_method(secret = String)
    secret
  end
end
