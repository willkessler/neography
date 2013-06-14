module Deja
  module Finders
    extend ActiveSupport::Concern

    def load_related(*relationships)
      get_related_nodes(self.id, relationships)
    end

    module ClassMethods
      def load(*ids)
        nodes = ids.map do |id|
          entity_array = load_entity(id)
          objectify(entity_array)
        end
        if ids.length == 1
          nodes.first
        else
          nodes
        end
      end

      def load_single(id, filter = :none)
        entity_array = load_entity(id, filter)
        objectify(entity_array)
      end

    end
  end
end
