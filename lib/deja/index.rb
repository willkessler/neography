module Deja
  module Index
    def add_to_index(index, key, value, unique = false)
      if self.is_a? Deja::Node
        Deja.neo.add_node_to_index(index, key, value, self.neo_id, unique)
      else
        Deja.neo.add_relationship_to_index(index, key, value)
      end
    end

    def remove_from_index(*args)
      if self.is_a? Deja::Node
        Deja.neo.neo_server.remove_node_from_index(*args)
      else
        Deja.neo.remove_relationship_from_index(*args)
      end
    end
  end
end
