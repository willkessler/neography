module Deja
  class Bridge
    class << self
      def is_index?(node_lookup)
        node_lookup.is_a?(Hash)
      end

      def cypher(&block)
        Neo4j::Cypher.query(&block)
      end

      def create_node(attributes = {})
        raise Deja::Error::InvalidParameter unless attributes
        raise Deja::Error::NoParameter if attributes.empty?
        cypher { node.new(attributes).neo_id }
      end

      def delete_node(node_id)
        cypher { node(node_id).del.both(rel().as(:r).del) }
      end

      def update_node(node, attributes)
        is_index?(node) ? update_node_by_index(node, attributes) : update_node_by_id(node, attributes)
      end

      def update_node_by_id(node_id, attributes)
        cypher do
          node(node_id).tap do |n|
            attributes.each do |key, value|
              n[key] = value
            end
          end
        end
      end

      def update_node_by_index(index_hash, attributes)
        cypher do
          node(node_id).tap do |n|
            attributes.each do |key, value|
              n[key] = value
            end
          end
        end
      end

      def create_relationship(start_node, end_node, name, direction = :none, attributes = {})
        case direction
        when :none
          cypher { create_path{ node(start_node) - rel(name).as(:r).neo_id.ret - node(end_node)} }
        when :out
          cypher { create_path{ node(start_node) > rel(name).as(:r).neo_id.ret > node(end_node)} }
        when :in
          cypher { create_path{ node(start_node) < rel(name).as(:r).neo_id.ret < node(end_node)} }
        else
          return false
        end
      end

      def delete_relationship(rel_id)
        cypher { rel(rel_id).del }
      end

      def get_single_relationship(rel_id)
        cypher { rel(rel_id) }
      end

      # includes origin node
      def get_node_with_rels(neo_id, rels)
        case rels
        when Array     then cypher { node(neo_id).ret - rel(*rels).ret - node.ret }
        when :all      then cypher { node(neo_id).ret.both(rel().ret).ret }
        when :outgoing then cypher { node(neo_id).ret.outgoing(rel().ret).ret }
        when :incoming then cypher { node(neo_id).ret.incoming(rel().ret).ret }
        when :none     then cypher { node(neo_id) }
        else cypher { node(neo_id).ret - rel(rels.to_sym).ret - node.ret }
        end
      end

      # does not include origin node
      def get_related_nodes(neo_id, rels)
        case rels
        when Array     then cypher { node(neo_id) - rel(*rels).ret - node.ret }
        when :all      then cypher { node(neo_id).both(rel().ret).ret }
        when :outgoing then cypher { node(neo_id).outgoing(rel().ret).ret }
        when :incoming then cypher { node(neo_id).incoming(rel().ret).ret }
        else cypher { node(neo_id) - rel(rels.to_sym).ret - node.ret }
        end
      end
    end
  end
end
