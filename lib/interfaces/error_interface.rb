module LowType
  class ErrorInterface
    attr_reader :file

    def error_type
      raise NotImplementedError
    end

    def error_message(value:)
      raise NotImplementedError
    end
  end
end
