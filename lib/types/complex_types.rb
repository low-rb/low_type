# frozen_string_literal: true

module LowType
  # TrueClass or FalseClass
  class Boolean; end
  class Tuple < Array; end
  class Status < Integer; end
  class Headers < Hash; end
  class HTML < String; end
  class JSON < String; end
  class XML < String; end
end
