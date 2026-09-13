# frozen_string_literal: true

# Benchmark: Plain Ruby vs untyped_methods shim vs rewrite_methods
#
# Compares three execution paths for calling a typed LowType method
# when type_checking is disabled:
#
#   1. Plain Ruby       -- baseline, no LowType involvement
#   2. Shim (old)       -- untyped_methods: define_method + super dispatch
#   3. Rewriter (new)   -- rewrite_methods: class_eval direct redefinition

require 'benchmark/ips'
require_relative '../lib/low_type'

# ---------------------------------------------------------------------------
# 1. Plain Ruby baseline -- no LowType, no overhead
# ---------------------------------------------------------------------------
class PlainKeyword
  def greet(name:, greeting: 'Hello')
    "#{greeting}, #{name}!"
  end
end

class PlainPositional
  def add(a, b = 0)
    a + b
  end
end

# ---------------------------------------------------------------------------
# 2. Shim (untyped_methods) -- old code path
#    type_checking: false routes to untyped_methods which uses define_method
#    + Lowkey re-lookup + super on every call
# ---------------------------------------------------------------------------
LowType.configure { |c| c.type_checking = false }

# Force shim path by temporarily pointing redefine to untyped_methods.
# We do this by reopening Redefiner and aliasing before the rewriter existed.
module Low
  class Redefiner
    class << self
      def redefine_shim(method_proxies:, class_proxy:, klass: nil)
        untyped_methods(method_proxies:, class_proxy:)
      end
    end
  end
end

# Patch LowType to use shim path
module LowType
  def self.included_shim(klass)
    file_path = Low::FileQuery.file_path(klass:)
    file_proxy = Lowkey.load(file_path, cache: false)
    class_proxy = file_proxy[klass.name]

    klass.include Low::ExpressionHelpers
    klass.extend Low::ExpressionHelpers
    klass.extend Low::TypeAccessors
    klass.extend Low::Types

    tp = TracePoint.new(:end) do |trace|
      next unless trace.self == klass

      class_proxy.class_binding = trace.binding
      Low::Evaluator.evaluate(method_proxies: class_proxy.keyed_methods, class_binding: class_proxy.class_binding)

      result = Low::Redefiner.redefine_shim(method_proxies: class_proxy.instance_methods, class_proxy:, klass:)
      klass.prepend result if result

      tp.disable
    end
    tp.enable
  end
end

# Load shim fixtures by including via included_shim
class ShimKeyword
  def greet(name: String, greeting: String | value('Hello'))
    "#{greeting}, #{name}!"
  end
end
LowType.included_shim(ShimKeyword)

class ShimPositional
  def add(a = Integer, b = Integer | value(0))
    a + b
  end
end
LowType.included_shim(ShimPositional)

# ---------------------------------------------------------------------------
# 3. Rewriter (rewrite_methods) -- new code path via class_eval
# ---------------------------------------------------------------------------
class RewriteKeyword
  include LowType

  def greet(name: String, greeting: String | value('Hello'))
    "#{greeting}, #{name}!"
  end
end

class RewritePositional
  include LowType

  def add(a = Integer, b = Integer | value(0))
    a + b
  end
end

# ---------------------------------------------------------------------------
# Run benchmarks
# ---------------------------------------------------------------------------
puts "\n== Keyword args benchmark =="
Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('plain ruby')    { PlainKeyword.new.greet(name: 'World') }
  x.report('shim (old)')    { ShimKeyword.new.greet(name: 'World') }
  x.report('rewriter (new)') { RewriteKeyword.new.greet(name: 'World') }

  x.compare!
end

puts "\n== Positional args benchmark =="
Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report('plain ruby')    { PlainPositional.new.add(1, 2) }
  x.report('shim (old)')    { ShimPositional.new.add(1, 2) }
  x.report('rewriter (new)') { RewritePositional.new.add(1, 2) }

  x.compare!
end
