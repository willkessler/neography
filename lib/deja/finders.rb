module Deja
  module Finders
    extend ActiveSupport::Concern

    def load_related(*relationships)
      hashster = self.class.load_related_nodes(self.id, :include => relationships)
      erectify(hashster)
    end

    module ClassMethods
      def load(id, options = {})
        options[:include] ||= :none
        entity_array = load_entity(id, options)
        objectify(entity_array)
      end

      def load_many(*ids)
        nodes = ids.map do |id|
          entity_array = load_entity(id)
          objectify(entity_array)
        end
        ids.length == 1 ? nodes.first : nodes
      end

    end
  end
end
