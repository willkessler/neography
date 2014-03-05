 module Deja
  class Bridge
    class << self
      def cypher(&block)
        Neo4j::Cypher.query(&block)
      end

      def is_index?(id)
        id.is_a?(Hash) && id[:index] && id[:key]
      end

      def is_query?(id)
        id.is_a?(Hash) && id[:index] && id[:query]
      end

      ## these methods take a cypher block context as an argument,
      ## it allows us to treat nodes/rels the same regardless of index or id
      def node(id, context, identifier = :root)
        return context.lookup(id[:index], id[:key], id[:value]).as(identifier) if is_index?(id)
        return context.query(id[:index], id[:query].gsub("'", %q(\\\'))).as(identifier) if is_query?(id)
        context.node(id).as(identifier)
      end

      def rel(id, context, identifier = :relation)
        return context.lookup_rel(id[:index], id[:key], id[:value]).as(identifier) if is_index?(id)
        return context.query_rel(id[:index], id[:query].gsub("'", %q(\\\'))).as(identifier) if is_query?(id)
        context.rel(id).as(identifier)
      end

      def apply_options(context, options = {})
        context = where(context, options[:where]) if options[:where]
        context = order(context, options[:order])   if options[:order]
        context = limit(context, options[:limit])   if options[:limit]
        context = skip(context, options[:offset])   if options[:offset]
        return select(context, options[:select]) if options[:select].present?
        return_query(context, options[:return_root])
      end

      def where(context, filters)
        context.where{|n| filters.each{|k, v| n[k] == v.to_s}}
      end

      def order(context, order_string)
        property, order = order_string.split(' ')
        if order.casecmp('ASC') == 0
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

      def select(context, properties)
        properties << :type
        context.ret { |n| properties.map{|p| node(:root)[p]} << node(:root).neo_id.as(:id)}
      end

      def return_query(context, return_root = :root_rel_end)
        context.ret { :root } if return_root == :root_only
        context.ret { [:relation, :end]} if return_root == :rel_end
        context.ret { [:root, :relation, :end] } if return_root == :root_rel_end
      end

      def create_node(attributes = {})
        raise Deja::Error::InvalidParameter unless attributes
        raise Deja::Error::NoParameter if attributes.empty?
        cypher { node.new(attributes).neo_id }
      end

      def delete_node(id)
        cypher {
          Deja::Bridge.node(id, self).del.both(rel().as(:relation).del)
        }
      end

      def update_node(id, attributes)
        cypher do
          Deja::Bridge.node(id, self).tap do |n|
            attributes.each do |key, value|
              n[key] = value.is_a?(String) ? value.gsub(/['"]/) { |s| "\\#{s}" } : value
            end
          end.ret
        end
      end

      def create_relationship(start_node, end_node, name, attributes = {})
        cypher { create_path{ Deja::Bridge.node(start_node, self, :root) > rel(name, attributes).as(:relation).neo_id.ret > Deja::Bridge.node(end_node, self, :end)} }
      end

      def get_relationship(id)
        cypher {
          r = node.as(:end) < Deja::Bridge.rel(id, self) < node.as(:root)
          Deja::Bridge.apply_options(r, {:return_root => :root_rel_end})
        }
      end

      def get_relationship_from_nodes(start_node, end_node, type)
        cypher {
          r = Deja::Bridge.node(start_node, self, :root) > rel(type).as(:relation) > Deja::Bridge.node(end_node, self, :end)
          Deja::Bridge.apply_options(r, {:return_root => :root_rel_end})
        }
      end

      def update_relationship(id, attributes = {})
        cypher do
          Deja::Bridge.rel(id, self).tap do |r|
            attributes.each do |key, value|
              r[key] = value.is_a?(String) ? value.gsub(/['"]/) { |s| "\\#{s}" } : value
            end
          end.ret
        end
      end

      def delete_relationship(id)
        cypher {
          Deja::Bridge.rel(id, self).del
        }
      end

      def get_nodes(id, opts = {})
        return single_node(id, opts) if opts[:include] == :none
        direction = opts[:direction] || :both
        rels = opts[:include] == :all ? nil : opts[:include]
        case direction
        when :out  then outgoing_rel(id, rels, opts)
        when :in   then incoming_rel(id, rels, opts)
        when :both then in_out_rel(id, rels, opts)
        else false
        end
      end

      def single_node(id, opts = {})
        opts[:return_root] = :root_only
        cypher {
          n = Deja::Bridge.node(id, self)
          Deja::Bridge.apply_options(n, opts)
        }
      end

      def outgoing_rel(id, rels = nil, opts = nil)
        cypher {
          r = Deja::Bridge.node(id, self).outgoing(rel(*rels).as(:relation)).as(:end)
          Deja::Bridge.apply_options(r, opts)
        }
      end

      def incoming_rel(id, rels = nil, opts = nil)
        cypher {
          r = Deja::Bridge.node(id, self).incoming(rel(*rels).as(:relation)).as(:end)
          Deja::Bridge.apply_options(r, opts)
        }
      end

      def in_out_rel(id, rels = nil, opts = nil)
        cypher {
          r = Deja::Bridge.node(id, self).both(rel(*rels).as(:relation)).as(:end)
          Deja::Bridge.apply_options(r, opts)
        }
      end

      def count_nodes(index)
        cypher {
          Deja::Bridge.node(index, self).count
        }
      end

      def count_relationships(index)
        cypher {
          Deja::Bridge.rel(index, self).count
        }
      end

      def count_related_nodes(id, rel = nil, direction = nil)
        case direction
        when :out_plural, :out_singular, :out
          cypher { node(id).outgoing(rel).count }
        when :in_plural, :in_singular, :in
          cypher { node(id).incoming(rel).count }
        else
          return false
        end
      end

      def count_connections(id)
        cypher { node(id).both().count }
      end
    end
  end
end
