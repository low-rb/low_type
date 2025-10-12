require 'prism'

module LowType
  class Parser
    attr_reader :parent_map, :method_defs

    def initialize(file_path:)
      root_node = Prism.parse_file(file_path).value

      parent_mapper = ParentMapper.new
      parent_mapper.visit(root_node)
      @parent_map = parent_mapper.parent_map

      method_visitor = MethodVisitor.new
      root_node.accept(method_visitor)
      @method_defs = method_visitor.method_defs
    end

    def class_method?(node)
      return true if node.is_a?(::Prism::SingletonClassNode)

      if (parent_node = @parent_map[node])
        return class_method?(parent_node)
      end

      false
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

  class ParentMapper < Prism::Visitor
    attr_reader :parent_map

    def initialize
      @parent_map = {}
      @current_parent = nil
    end

    def visit(node)
      @parent_map[node] = @current_parent

      old_parent = @current_parent
      @current_parent = node

      node.compact_child_nodes.each do |n|
        visit(n)
      end

      @current_parent = old_parent
    end
  end
end
