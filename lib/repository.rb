# frozen_string_literal: true

module LowType
  class Repository
    class << self
      def method_proxy(name:, object:)
        object.instance_of?(Class) ? object.low_methods[name] : object.class.low_methods[name] || Object.low_methods[name]
      end
    end
  end
end
