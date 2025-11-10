# frozen_string_literal: true

require_relative '../../lib/low_type'

include LowType # rubocop:disable Style/MixinUsage

def arg(greeting)
  greeting
end

def arg_and_default_value(greeting = 'Hello')
  greeting
end

def typed_arg(greeting = String)
  greeting
end

class << self
  def say_goodbye(goodbye)
    goodbye
  end
end

private # rubocop:disable Lint/UselessAccessModifier

# All methods defined on main object are private so this makes no difference.
def private_arg
  'Goodbye'
end
