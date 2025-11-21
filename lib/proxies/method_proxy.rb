# frozen_string_literal: true

require 'forwardable'

module LowType
  class MethodProxy
    extend Forwardable

    attr_reader :name, :file, :params, :return_proxy

    # File is queried by redefiner but not sinatra adapter nor type accessors.
    def_delegators :@file, :start_line, :end_line, :lines?

    def initialize(name:, file: nil, params: [], return_proxy: nil)
      @name = name
      @file = file
      @params = params
      @return_proxy = return_proxy
    end
  end
end
