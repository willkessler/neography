module Deja
  module RestIndex
    # node indexes
    def list_node_indexes
      Deja.neo.list_node_indexes
    end
    alias_method :list_indexes, :list_node_indexes

    def list_relationship_indexes
      Deja.neo.list_relationship_indexes
    end

    def create_node_index(name, type = "exact", provider = "lucene")
      Deja.neo.create_node_index(name, type, provider)
    end

    def create_node_auto_index(type = "exact", provider = "lucene")
      Deja.neo.create_node_auto_index(type, provider)
    end

    def create_unique_node(index, key, value, props={})
      Deja.neo.create_unique_node(index, key, value, props)
    end

    def add_node_to_index(index, key, value, neo_id, unique = false)
      Deja.neo.add_node_to_index(index, key, value, neo_id, unique)
    end

    def remove_node_from_index(index, id_or_key, id_or_value = nil, id = nil)
      Deja.neo.remove_node_from_index(index, id_or_key, id_or_value, id)
    end
    alias_method :remove_from_index, :remove_node_from_index

    def get_node_index(index, key, value)
      Deja.neo.get_node_index(index, key, value)
    end
    alias_method :get_index, :get_node_index

    def find_node_index(index, key_or_query, value = nil)
      Deja.neo.find_node_index(index, key_or_query, value)
    end

    # auto node indexes
    def get_node_auto_index(key, value)
      Deja.neo.get_node_auto_index(key, value)
    end

    def find_node_auto_index(key_or_query, value = nil)
      Deja.neo.find_node_auto_index(key_or_query, value)
    end

    def get_node_auto_index_status
      Deja.neo.get_node_auto_index_status
    end

    def set_node_auto_index_status(change_to = true)
      Deja.neo.set_node_auto_index_status(change_to)
    end

    def get_node_auto_index_properties
      Deja.neo.get_node_auto_index_properties
    end

    def add_node_auto_index_property(property)
      Deja.neo.add_node_auto_index_property(property)
    end

    def remove_node_auto_index_property(property)
      Deja.neo.remove_node_auto_index_property(property)
    end

    # relationship indexes
    def create_relationship_index(name, type = "exact", provider = "lucene")
      Deja.neo.create_relationship_index(name, type, provider)
    end

    def create_relationship_auto_index(type = "exact", provider = "lucene")
      Deja.neo.create_relationship_auto_index(type, provider)
    end

    def add_relationship_to_index(index, key, value, id)
      Deja.neo.add_relationship_to_index(index, key, value, id)
    end

    def remove_relationship_from_index(index, id_or_key, id_or_value = nil, id = nil)
      Deja.neo.remove_relationship_from_index(index, id_or_key, id_or_value, id)
    end

    def create_unique_relationship(index, key, value, type, from, to)
      Deja.neo.create_unique_relationship(index, key, value, type, from, to)
    end

    def get_relationship_index(index, key, value)
      Deja.neo.get_relationship_index(index, key, value)
    end

    def find_relationship_index(index, key_or_query, value = nil)
      Deja.neo.find_relationship_index(index, key_or_query, value)
    end

    # relationship auto indexes
    def get_relationship_auto_index(key, value)
      Deja.neo.get_relationship_auto_index(key, value)
    end

    def find_relationship_auto_index(key_or_query, value = nil)
      Deja.neo.find_relationship_auto_index(key_or_query, value)
    end

    def get_relationship_auto_index_status
      Deja.neo.get_relationship_auto_index_status
    end

    def set_relationship_auto_index_status(change_to = true)
      Deja.neo.set_relationship_auto_index_status(change_to)
    end

    def get_relationship_auto_index_properties
      Deja.neo.get_relationship_auto_index_properties
    end

    def add_relationship_auto_index_property(property)
      Deja.neo.add_relationship_auto_index_property(property)
    end

    def remove_relationship_auto_index_property(property)
      Deja.neo.remove_relationship_auto_index_property(property)
    end
  end
end
