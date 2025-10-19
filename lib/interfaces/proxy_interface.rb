module LowType
  class ProxyInterface
    def error_type
      raise NotImplementedError
    end

    def error_message(value:, line: nil)
      raise NotImplementedError
    end
  end
end
