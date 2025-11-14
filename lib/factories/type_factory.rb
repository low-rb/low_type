# frozen_string_literal: true

module LowType
  class TypeFactory
    class << self
      def complex_type(parent_type)
        Class.new(parent_type) do
          def self.match?(value:)
            return true if value.instance_of?(self.class) || value.instance_of?(superclass)

            false
          end
        end
      end
    end
  end
end
