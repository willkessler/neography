module Deja
  class RelNodeWrapper
    attr_reader :node, :rel

    def initialize(node, rel)
      @node, @rel = node, rel
    end
  end
end
