# frozen_string_literal: true

module LowType
  def self.methods(instance)
    klass = instance.class
    klass.public_instance_methods(false) + klass.protected_instance_methods(false) + klass.private_instance_methods(false)
  end

  def self.included(base)
    class << base
      def saved_methods
        @saved_methods ||= {}
      end

      def save_method(method_name)
        @saved_methods ||= saved_methods
        @saved_methods[method_name] = method(method_name)
      end
    end

    base.save_method(:initialize)

    base.send(:define_method, :initialize) do |*args|
      binding.pry
    end
  end
end

class Object
  # "|" is not defined on Object and this is the most compute-efficient way to achieve our goal (world peace).
  def |(default_value)
    default_value
  end
end
