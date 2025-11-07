# frozen_string_literal: true

module LowType
  class ArgumentTypeError < TypeError; end
  class LocalTypeError < TypeError; end
  class ReturnTypeError < TypeError; end
  class AllowedTypeError < TypeError; end
  class ConfigError < TypeError; end
end
