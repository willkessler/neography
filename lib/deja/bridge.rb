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

      def delete_node(id)
        is_index?(id) ? delete_node_by_index(id) : delete_node_by_id(id)
      end

      def delete_node_by_index(id)
        cypher { lookup(id[:index], id[:key], id[:value]).del.both(rel().as(:r).del) }
      end

      def delete_node_by_id(neo_id)
        cypher { node(neo_id).del.both(rel().as(:r).del) }
      end

      def update_node(id, attributes)
        is_index?(id) ? update_node_by_index(id, attributes) : update_node_by_id(id, attributes)
      end

      def update_node_by_id(neo_id, attributes)
        cypher do
          node(neo_id).tap do |n|
            attributes.each do |key, value|
              n[key] = value
            end
          end
        end
      end

      def update_node_by_index(id, attributes)
        cypher do
          lookup(id[:index], id[:key], id[:value]).tap do |n|
            attributes.each do |key, value|
              n[key] = value
            end
          end
        end
      end

      def create_relationship(start_node, end_node, name, direction = :none, attributes = {})
        case direction
        when :none
          cypher { create_path{ node(start_node) - rel(name, attributes).as(:r).neo_id.ret - node(end_node)} }
        when :out
          cypher { create_path{ node(start_node) > rel(name, attributes).as(:r).neo_id.ret > node(end_node)} }
        when :in
          cypher { create_path{ node(start_node) < rel(name, attributes).as(:r).neo_id.ret < node(end_node)} }
        else
          return false
        end
      end

      def delete_relationship(id)
        is_index?(id) ? delete_relationship_by_index(id) : delete_relationship_by_id(id)
      end

      def delete_relationship_by_index(id)
        cypher { lookup_rel(id[:index], id[:key], id[:value]).del }
      end

      def delete_relationship_by_id(neo_id)
        cypher { rel(neo_id).del }
      end

      def get_single_relationship(rel_id)
        cypher { rel(rel_id) }
      end

      # includes origin node
      def get_node_with_rels(id, rels)
        is_index?(id) ? nodes_from_index(id, rels) : nodes_from_id(id, rels)
      end

      def nodes_from_index(id, rels)
        case rels
        when Array
          cypher {
            lookup(id[:index], id[:key], id[:value]).ret - rel(*rels).ret - node.ret
          }
        when :all
          cypher {
            lookup(id[:index], id[:key], id[:value]).ret.both(rel().ret).ret
          }
        when :outgoing
          cypher {
            lookup(id[:index], id[:key], id[:value]).ret.outgoing(rel().ret).ret
          }
        when :incoming
          cypher {
            lookup(id[:index], id[:key], id[:value]).ret.incoming(rel().ret).ret
          }
        when :none
          cypher {
            lookup(id[:index], id[:key], id[:value])
          }
        else
          cypher {
            lookup(id[:index], id[:key], id[:value]).ret - rel(rels.to_sym).ret - node.ret
          }
        end
      end

      def nodes_from_id(neo_id, rels)
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
      def get_related_nodes(id, rels)
        is_index?(id) ? rels_from_index(id, rels) : rels_from_id(id, rels)
      end

      def rels_from_index(id, rels)
        case rels
        when Array
          cypher {
            lookup(id[:index], id[:key], id[:value]) - rel(*rels).ret - node.ret
          }
        when :all
          cypher {
            lookup(id[:index], id[:key], id[:value]).both(rel().ret).ret
          }
        when :outgoing
          cypher {
            lookup(id[:index], id[:key], id[:value]).outgoing(rel().ret).ret
          }
        when :incoming
          cypher {
            lookup(id[:index], id[:key], id[:value]).incoming(rel().ret).ret
          }
        else
          cypher {
            lookup(id[:index], id[:key], id[:value]) - rel(rels.to_sym).ret - node.ret
          }
        end
      end

      def rels_from_id(neo_id, rels)
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
