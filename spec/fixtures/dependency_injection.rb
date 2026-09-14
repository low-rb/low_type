# frozen_string_literal: true

require 'providers'
require_relative '../../lib/lowtype'

Providers.define(:dependency) do
  'mock dependency'
end

Providers.define(:symbol) do
  'mock symbol dependency'
end

Providers.define('string') do
  'mock string dependency'
end

class DependencyInjection
  include LowType

  def dependency(dependency: Dependency)
    dependency
  end

  def symbol_dependency(dependency: Dependency | :symbol)
    dependency
  end

  def string_dependency(dependency: Dependency | 'string')
    dependency
  end
end
