 module Deja
  class Bridge
    class << self
      def is_index?(id_or_index)
        id_or_index.is_a?(Hash)
      end

      def cypher(&block)
        Neo4j::Cypher.query(&block)
      end

      ## these methods take a cypher block context as an argument,
      ## it allows us to treat nodes the same regardless of index or id
      def node(id, context, return_root = true)
        if return_root
          is_index?(id) ? context.lookup(id[:index], id[:key], id[:value]).ret : context.node(id).ret
        else
          is_index?(id) ? context.lookup(id[:index], id[:key], id[:value]) : context.node(id)
        end
      end

      def rel(id, context, return_root = true)
        if return_root
          is_index?(id) ? context.lookup_rel(id[:index], id[:key], id[:value]).ret : context.rel(id).ret
        else
          is_index?(id) ? context.lookup_rel(id[:index], id[:key], id[:value]) : context.rel(id)
        end
      end

      def attach_filter(result, filter = nil)
        result.where{|n| n[:type] == filter.to_s.camelize} if filter
        result
      end

      def create_node(attributes = {})
        raise Deja::Error::InvalidParameter unless attributes
        raise Deja::Error::NoParameter if attributes.empty?
        cypher { node.new(attributes).neo_id }
      end

      def delete_node(id)
        cypher{
          Deja::Bridge.node(id, self, false).del.both(rel().as(:r).del)
        }
      end

      def update_node(id, attributes)
        cypher do
          Deja::Bridge.node(id, self, false).tap do |n|
            attributes.each do |key, value|
              n[key] = value
            end
          end
        end
      end

      def create_relationship(start_node, end_node, name, attributes = {})
        cypher { create_path{ Deja::Bridge.node(start_node, self, false) > rel(name, attributes).as(:r).neo_id.ret > Deja::Bridge.node(end_node, self, false)} }
      end

      def get_relationship(id)
        cypher { node.ret < Deja::Bridge.rel(id, self) < node.ret }
      end

      def get_relationship_from_nodes(start_node, end_node, type)
        cypher { Deja::Bridge.node(start_node, self) > rel(type).ret > Deja::Bridge.node(end_node, self) }
      end

      def update_relationship(id, attributes = {})
        cypher do
          Deja::Bridge.rel(id, self).tap do |r|
            attributes.each do |key, value|
              r[key] = value
            end
          end
        end
      end

      def delete_relationship(id)
        cypher {
          Deja::Bridge.rel(id, self, false).del
        }
      end

      def get_related_nodes(id, opts = {})
        opts[:direction]   ||= :both
        opts[:filter]      ||= nil
        rels = opts[:include] == :all ? nil : opts[:include]
        case opts[:direction]
        when :out  then outgoing_rel(id, rels, opts[:return_root], opts[:filter])
        when :in   then incoming_rel(id, rels, opts[:return_root], opts[:filter])
        when :both then in_out_rel(id, rels, opts[:return_root], opts[:filter])
        else false
        end
      end

      def outgoing_rel(id, rels = nil, root = nil, filter = nil)
        cypher {
          r = Deja::Bridge.node(id, self, root).outgoing(rel(*rels).ret)
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end

      def incoming_rel(id, rels = nil, root = nil, filter = nil)
        cypher {
          r = Deja::Bridge.node(id, self, root).incoming(rel(*rels).ret)
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end

      def in_out_rel(id, rels = nil, root = nil, filter = nil)
        cypher {
          r = Deja::Bridge.node(id, self, root).both(rel(*rels).ret)
          ret Deja::Bridge.attach_filter(r, filter)
        }
      end

      def count_rels(id, rel = nil, direction = nil)
        case direction
        when :out_plural, :out_singular
          cypher { node(id).outgoing(rel).count }
        when :in_plural, :in_singular
          cypher { node(id).incoming(rel).count }
        else
          return false
        end
      end
    end
  end
end
