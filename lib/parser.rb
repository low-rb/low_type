# frozen_string_literal: true

require 'prism'

module LowType
  class Parser
    attr_reader :parent_map, :instance_methods, :class_methods, :private_start_line

    def initialize(file_path:)
      @root_node = Prism.parse_file(file_path).value

      parent_mapper = ParentMapper.new
      parent_mapper.visit(@root_node)
      @parent_map = parent_mapper.parent_map

      method_visitor = MethodDefVisitor.new(@parent_map)
      @root_node.accept(method_visitor)

      @instance_methods = method_visitor.instance_methods
      @class_methods = method_visitor.class_methods
      @private_start_line = method_visitor.private_start_line
    end

    def method_calls(method_names:)
      block_visitor = MethodCallVisitor.new(parent_map: @parent_map, method_names:)
      @root_node.accept(block_visitor)
      block_visitor.method_calls
    end

    # Only a lambda defined immediately after a method's parameters/block is considered a return type expression.
    def self.return_type(method_node:)
      # Method statements.
      statements_node = method_node.compact_child_nodes.find { |node| node.is_a?(Prism::StatementsNode) }

      # Block statements.
      if statements_node.nil?
        block_node = method_node.compact_child_nodes.find { |node| node.is_a?(Prism::BlockNode) }
        statements_node = block_node.compact_child_nodes.find { |node| node.is_a?(Prism::StatementsNode) } if block_node
      end

      return nil if statements_node.nil? # Sometimes developers define methods without code inside them.

      node = statements_node.body.first
      return node if node.is_a?(Prism::LambdaNode)

      nil
    end
  end

  class MethodDefVisitor < Prism::Visitor
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
      @private_start_line = node.start_line if node.name == :private && node.respond_to?(:start_line)
    end

    private

    def class_method?(node)
      return true if node.is_a?(::Prism::DefNode) && node.receiver.instance_of?(Prism::SelfNode) # self.method_name
      return true if node.is_a?(::Prism::SingletonClassNode) # class << self

      if (parent_node = @parent_map[node])
        return class_method?(parent_node)
      end

      false
    end
  end

  class MethodCallVisitor < Prism::Visitor
    attr_reader :method_calls

    def initialize(parent_map:, method_names:)
      @parent_map = parent_map
      @method_names = method_names

      @method_calls = []
    end

    def visit_call_node(node)
      @method_calls << node if @method_names.include?(node.name)

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
