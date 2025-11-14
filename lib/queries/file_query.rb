# frozen_string_literal: true

module LowType
  class FileQuery
    class << self
      def file_path(klass:)
        includer_line = line_from_class(klass:) || line_from_include || ''
        includer_line.split(':').first || ''
      end

      private

      def line_from_class(klass:)
        class_name = klass.to_s.split(':').last # Also remove the module namespaces from the class.
        caller.find { |callee| callee.end_with?("<class:#{class_name}>'") }
      end

      def line_from_include
        caller.find { |callee| callee.end_with?("include'") }
      end
    end
  end
end
