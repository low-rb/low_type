# frozen_string_literal: true

module LowType
  class Repository
    class << self
      def save(method:, klass:)
        klass.low_methods[method.name] = method
      end

      def delete(name:, klass:)
        klass.low_methods.delete(name)
      end

      def load(name:, object:)
        singleton(object:).low_methods[name]
      end

      # TODO: export() to RBS

      private

      def singleton(object:)
        object.instance_of?(Class) ? object : object.class || Object
      end
    end
  end
end
