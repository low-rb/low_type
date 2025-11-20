# frozen_string_literal: true

require 'forwardable'

module LowType
  class ClassProxy
    extend Forwardable

    attr_reader :name, :klass, :file, :private_start_line

    def_delegators :@file, :start_line, :end_line, :lines?

    def initialize(klass:, file:, private_start_line:)
      @name = klass.to_s
      @klass = klass
      @file = file
      @private_start_line = private_start_line
    end
  end
end
