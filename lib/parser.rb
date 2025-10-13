require 'prism'

module LowType
  class Parser
    attr_reader :parent_map, :instance_methods, :class_methods, :private_start_line

    def initialize(file_path:)
      root_node = Prism.parse_file(file_path).value

      parent_mapper = ParentMapper.new
      parent_mapper.visit(root_node)
      @parent_map = parent_mapper.parent_map

      method_visitor = MethodVisitor.new(@parent_map)
      root_node.accept(method_visitor)

      @instance_methods = method_visitor.instance_methods
      @class_methods = method_visitor.class_methods
      @private_start_line = method_visitor.private_start_line
    end
  end

  class MethodVisitor < Prism::Visitor
    attr_reader :class_methods, :instance_methods, :private_start_line

    def initialize(parent_map)
      @parent_map = parent_map

      @instance_methods = []
      @class_methods = []
      @private_start_line = nil
    end

    def visit_def_node(node)
      if class_method?(node)
        @class_methods << node
      else
        @instance_methods << node
      end

      super # Continue walking the tree.
    end

    def visit_call_node(node)
      @private_start_line = node.start_line if node.name == :private
    end

    private

    def class_method?(node)
      return true if node.is_a?(::Prism::DefNode) && node.receiver.class == Prism::SelfNode # self.method_name
      return true if node.is_a?(::Prism::SingletonClassNode) # class << self

      if (parent_node = @parent_map[node])
        return class_method?(parent_node)
      end

      false
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
