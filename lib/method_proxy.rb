module LowType
  class MethodProxy
    attr_reader :name, :params, :return

    def initialize(name:, params:)
      @name = name
      @params = params
      @return = nil
    end
  end
end
