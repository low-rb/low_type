# frozen_string_literal: true

module LowType
  class ErrorInterface
    attr_reader :file

    def initialize
      @file = nil
      @output_mode = LowType.config.output_mode
      @output_size = LowType.config.output_size
    end

    def output(value:)
      case @output_mode
      when :type
        value.class
      when :value
        value.inspect[0...@output_size]
      else
        'REDACTED'
      end
    end

    def error_type
      raise NotImplementedError
    end

    def error_message(value:)
      raise NotImplementedError
    end
  end
end
