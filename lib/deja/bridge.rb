 module Deja
  class Bridge
    class << self
      def cypher(&block)
        Neo4j::Cypher.query(&block)
      end

      def is_index?(id)
        id.is_a?(Hash) && id[:index] && id[:key] && id[:value]
      end

      def is_query?(id)
        id.is_a?(Hash) && id[:index] && id[:query]
      end

      ## these methods take a cypher block context as an argument,
      ## it allows us to treat nodes/rels the same regardless of index or id
      def node(id, context, return_root = true)
        if return_root
          return context.lookup(id[:index], id[:key], id[:value]).ret if is_index?(id)
          return context.query(id[:index], id[:query]).ret if is_query?(id)
          context.node(id).ret
        else
          return context.lookup(id[:index], id[:key], id[:value]) if is_index?(id)
          return context.query(id[:index], id[:query]) if is_query?(id)
          context.node(id)
        end
      end

      def rel(id, context, return_root = true)
        if return_root
          return context.lookup_rel(id[:index], id[:key], id[:value]).ret if is_index?(id)
          return context.query_rel(id[:index], id[:query]).ret if is_query?(id)
          context.rel(id).ret
        else
          return context.lookup_rel(id[:index], id[:key], id[:value]) if is_index?(id)
          return context.query_rel(id[:index], id[:query]) if is_query?(id)
          context.rel(id)
        end
      end

      def apply_options(context, options = {})
        context = filter(context, options[:filter]) if options[:filter]
        context = order(context, options[:order])   if options[:order]
        context = limit(context, options[:limit])   if options[:limit]
        context = skip(context, options[:offset])   if options[:offset]
        context
      end

      def filter(context, filter)
        context.where{|n| n[:type] == filter.to_s.camelize}
      end

      def order(context, order_string)
        property, order = order_string.split(' ')
        if order == 'ASC'
          context.asc(property.to_sym)
        else
          context.desc(property.to_sym)
        end
      end

      def limit(context, size)
        context.limit(size)
      end

      def skip(context, offset)
        context.skip(offset)
      end

      def create_node(attributes = {})
        raise Deja::Error::InvalidParameter unless attributes
        raise Deja::Error::NoParameter if attributes.empty?
        cypher { node.new(attributes).neo_id }
      end

      def delete_node(id)
        cypher {
          Deja::Bridge.node(id, self, false).del.both(rel().as(:r).del)
        }
      end

      def update_node(id, attributes)
        cypher do
          Deja::Bridge.node(id, self, false).tap do |n|
            attributes.each do |key, value|
              n[key] = value
            end
          end.ret
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
          end.ret
        end
      end

      def delete_relationship(id)
        cypher {
          Deja::Bridge.rel(id, self, false).del
        }
      end

      def get_nodes(id, opts = {})
        return single_node(id) if opts[:include] == :none
        opts[:direction]   ||= :both
        rels = opts[:include] == :all ? nil : opts[:include]
        case opts[:direction]
        when :out  then outgoing_rel(id, rels, opts[:return_root], opts)
        when :in   then incoming_rel(id, rels, opts[:return_root], opts)
        when :both then in_out_rel(id, rels, opts[:return_root], opts)
        else false
        end
      end

      def single_node(id)
        cypher { Deja::Bridge.node(id, self, true) }
      end

      def outgoing_rel(id, rels = nil, root = nil, opts = nil)
        cypher {
          r = Deja::Bridge.node(id, self, root).outgoing(rel(*rels).ret)
          ret Deja::Bridge.apply_options(r, opts)
        }
      end

      def incoming_rel(id, rels = nil, root = nil, opts = nil)
        cypher {
          r = Deja::Bridge.node(id, self, root).incoming(rel(*rels).ret)
          ret Deja::Bridge.apply_options(r, opts)
        }
      end

      def in_out_rel(id, rels = nil, root = nil, opts = nil)
        cypher {
          r = Deja::Bridge.node(id, self, root).both(rel(*rels).ret)
          ret Deja::Bridge.apply_options(r, opts)
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
