require 'prism'

module LowType
  class Parser
    attr_reader :method_defs

    def initialize(file_path:)
      root_node = Prism.parse_file(file_path).value

      method_visitor = MethodVisitor.new
      root_node.accept(method_visitor)
      @method_defs = method_visitor.method_defs
    end
  end

  class MethodVisitor < Prism::Visitor
    attr_reader :method_defs

    def initialize
      @method_defs = []
    end

    def visit_def_node(node)
      @method_defs << node
      super # Continue walking the tree.
    end
  end
end
