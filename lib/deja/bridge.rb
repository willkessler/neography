 module Deja
  class Bridge
    class << self
      def is_index?(id_or_index)
        id_or_index.is_a?(Hash)
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

      def create_relationship(start_node, end_node, name, attributes = {})
        cypher { create_path{ node(start_node) > rel(name, attributes).as(:r).neo_id.ret > node(end_node)} }
      end

      def create_relationship_from_index(start_node, end_node, name, attributes = {})
        cypher { create_path{ lookup(start_node[:index], start_node[:key], start_node[:value]) > rel(name, attributes).as(:r).neo_id.ret > lookup(end_node[:index], end_node[:key], end_node[:value])} }
      end

      def get_relationship(index_or_id)
        is_index?(index_or_id) ? rels_from_index(index_or_id) : rels_from_id(index_or_id)
      end

      def rels_from_index(index)
        cypher { node.ret > lookup_rel(index[:index], index[:key], index[:value]).ret > node.ret }
      end

      def rels_from_id(id, opts = {})
        cypher { node.ret > rel(id).ret > node.ret }
      end

      def update_relationship(index_or_id, opts = {})
        is_index?(index_or_id) ? update_relationship_by_index(index_or_id, opts) : update_relationship_by_id(index_or_id, opts)
      end

      def update_relationship_by_index(index, attributes)
        cypher do
          lookup_rel(index[:index], index[:key], index[:value]).tap do |r|
            attributes.each do |key, value|
              r[key] = value
            end
          end
        end
      end

      def update_relationship_by_id(id, attributes)
        cypher do
          rel(id).tap do |r|
            attributes.each do |key, value|
              r[key] = value
            end
          end
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

      # includes origin node
      def get_node_with_rels(id, opts = {})
        opts[:direction] ||= :both
        is_index?(id) ? nodes_from_index(id, opts) : nodes_from_id(id, opts)
      end

      def nodes_from_id(neo_id, opts)
        return cypher { node(neo_id) } unless opts[:include]
        rels = opts[:include] == :all ? nil : opts[:include]
        case opts[:direction]
        when :out  then outgoing_triplet(neo_id, rels)
        when :in   then incoming_triplet(neo_id, rels)
        when :both then in_out_triplet(neo_id, rels)
        else false
        end
      end

      def nodes_from_index(index, opts)
        return cypher { lookup(index[:index], index[:key], index[:value])} unless opts[:include]
        rels = opts[:include] == :all ? nil : opts[:include]
        case opts[:direction]
        when :out  then idx_outgoing_triplet(index, rels)
        when :in   then idx_incoming_triplet(index, rels)
        when :both then idx_in_out_triplet(index, rels)
        else false
        end
      end

      def rel_or_nil(rels)
        rels == :all ? nil : rels
      end

      def outgoing_triplet(id, rels = nil)
        rels = rel_or_nil(rels)
        cypher { node(id).ret.outgoing(rel(*rels).ret).ret }
      end

      def idx_outgoing_triplet(index, rels = nil)
        rels = rel_or_nil(rels)
        cypher { lookup(id[:index], id[:key], id[:value]).ret.outgoing(rel(*rels).ret).ret }
      end

      def incoming_triplet(id, rels = nil)
        rels = rel_or_nil(rels)
        cypher { node(id).ret.incoming(rel(*rels).ret).ret }
      end

      def idx_incoming_triplet(index, rels = nil)
        rels = rel_or_nil(rels)
        cypher { lookup(id[:index], id[:key], id[:value]).ret.incoming(rel(*rels).ret).ret }
      end

      def in_out_triplet(id, rels = nil)
        rels = rel_or_nil(rels)
        cypher { node(id).ret.both(rel(*rels).ret).ret }
      end

      def idx_in_out_triplet(index, rels = nil)
        rels = rel_or_nil(rels)
        cypher { lookup(index[:index], index[:key], index[:value]).ret.both(rel(*rels).ret).ret }
      end

      # does not include origin node
      def get_related_nodes(id, opts = {})
        opts[:direction] ||= :both
        is_index?(id) ? rels_from_node_index(id, opts) : rels_from_node_id(id, opts)
      end

      def rels_from_node_id(neo_id, opts)
        rels = opts[:include] == :all ? nil : opts[:include]
        case opts[:direction]
        when :out  then outgoing_pair(neo_id, rels, opts[:filter])
        when :in   then incoming_pair(neo_id, rels, opts[:filter])
        when :both then in_out_pair(neo_id, rels, opts[:filter])
        else false
        end
      end

      def rels_from_node_index(index, opts)
        rels = opts[:include] == :all ? nil : opts[:include]
        case opts[:direction]
        when :out  then idx_outgoing_pair(index, rels, opts[:filter])
        when :in   then idx_incoming_pair(index, rels, opts[:filter])
        when :both then idx_in_out_pair(index, rels, opts[:filter])
        else false
        end
      end

      def attach_filter(result, filter = nil)
        result.where{|n| n[:type] == filter.to_s.camelize}.ret if filter
        result
      end

      def outgoing_pair(id, rels = nil, filter = nil)
        cypher {
          r = node(id).outgoing(rel(*rels).ret)
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end

      def idx_outgoing_pair(index, rels = nil, filter = nil)
        cypher {
          r = lookup(index[:index], index[:key], index[:value]).outgoing(rel(*rels).ret).ret
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end

      def incoming_pair(id, rels = nil, filter = nil)
        cypher {
          r = node(id).incoming(rel(*rels).ret).ret
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end

      def idx_incoming_pair(index, rels = nil, filter = nil)
        cypher {
          r = lookup(index[:index], index[:key], index[:value]).incoming(rel(*rels).ret).ret
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end

      def in_out_pair(id, rels = nil, filter = nil)
        cypher {
          r = node(id).both(rel(*rels).ret).ret
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end

      def idx_in_out_pair(index, rels = nil, filter = nil)
        cypher {
          r = lookup(index[:index], index[:key], index[:value]) - rel(*rels).ret - node.ret
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end
    end
  end
end
