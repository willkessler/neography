module Deja
  module Finders
    extend ActiveSupport::Concern

    def related_nodes(*relationships)
      related_nodes = Deja::Query.load_related_nodes(self.id, :include => relationships)
      erectify(related_nodes)
    end

    module ClassMethods
      def load(id, index = false, options = {})
        options[:include] ||= :none
        entity_array = Deja::Query.load_node(id, options)
        objectify(entity_array)
      end

      def load_many(*ids)
        nodes = ids.map do |id|
          entity_array = Deja::Query.load_node(id)
          objectify(entity_array)
        end
        ids.length == 1 ? nodes.first : nodes
      end
    end
  end
end
