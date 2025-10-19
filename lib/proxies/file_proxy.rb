module LowType
  class FileProxy
    attr_reader :path, :line, :scope

    def initialize(path:, line:, scope:)
      @path = path
      @line = line
      @scope = scope
    end
  end
end
