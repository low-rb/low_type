module LowType
  class MethodProxy
    attr_reader :name, :params, :return_proxy

    def initialize(name:, params: [], return_proxy: nil)
      @name = name
      @params = params
      @return_proxy = return_proxy
    end
  end
end
