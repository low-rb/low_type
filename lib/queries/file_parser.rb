# frozen_string_literal: true

require 'prism'
require_relative '../proxies/class_proxy'

module LowType
  class FileParser
    attr_reader :parent_map, :instance_methods, :class_methods, :class_proxy

    def initialize(klass:, file_path:)
      @root_node = Prism.parse_file(file_path).value

      parent_mapper = ParentMapper.new
      parent_mapper.visit(@root_node)
      @parent_map = parent_mapper.parent_map

      method_visitor = MethodDefVisitor.new(root_node: @root_node, parent_map:, klass:, file_path:)
      @root_node.accept(method_visitor)

      @instance_methods = method_visitor.instance_methods
      @class_methods = method_visitor.class_methods
      @class_proxy = ClassProxy.new(klass:, file: method_visitor.file_proxy, private_start_line: method_visitor.private_start_line)
    end

    def method_calls(method_names:)
      block_visitor = MethodCallVisitor.new(parent_map:, method_names:)
      @root_node.accept(block_visitor)
      block_visitor.method_calls
    end

    class << self
      # Only a lambda defined immediately after a method's parameters/block is considered a return type expression.
      def return_type(method_node:)
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
  end

  class MethodDefVisitor < Prism::Visitor
    attr_reader :class_methods, :instance_methods, :file_proxy, :private_start_line

    def initialize(root_node:, parent_map:, klass:, file_path:)
      @parent_map = parent_map
      @klass = klass

      @instance_methods = {}
      @class_methods = {}

      end_line = root_node.respond_to?(:end_line) ? root_node.end_line : nil
      @file_proxy = FileProxy.new(path: file_path, start_line: 0, end_line:, scope: klass.to_s)
      @private_start_line = nil
    end

    def visit_def_node(node)
      if class_method?(node)
        @class_methods[node.name] = node
      else
        @instance_methods[node.name] = node
      end

      super # Continue walking the tree.
    end

    def visit_call_node(node)
      return super unless node.name == :private && node.respond_to?(:start_line) && file_proxy.start_line && file_proxy.end_line

      @private_start_line = node.start_line if node.start_line > file_proxy.start_line && node.start_line < file_proxy.end_line

      super
    end

    def visit_class_node(node)
      if node.name == @klass.to_s.to_sym
        file_proxy.start_line = node.class_keyword_loc.start_line
        file_proxy.end_line = node.end_keyword_loc.end_line
      end

      super
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
