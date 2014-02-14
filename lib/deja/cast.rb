module Deja
  module Cast

    extend ActiveSupport::Concern

    # creating relationships to be attached to already exisitng objects
    def erectify(hash, direction = :out)
      self.class.sans_initial_node(hash, self, direction)
    end

    module ClassMethods
      # creating objects and their relationships (if any)
      def objectify(array)
        if array.present?
          n_array = array.map { |node| with_initial_node(node) }
          n_array.size == 1 ? n_array.first : n_array
        end
      end

      def relationize(array)
        if array.present?
          r_array = array.map { |rel| with_initial_node(rel, false) }
          r_array.size == 1 ? r_array.first : r_array
        end
      end

      def with_initial_node(entity_array, return_node = true)
        node_class = entity_array[:type].constantize
        initial_node = node_class.new(entity_array.except(:id).except(:relationships))
        initial_node.instance_variable_set('@id', entity_array[:id])
        relationship = sans_initial_node(entity_array[:relationships], initial_node)
        return_node ? initial_node : relationship
      end

      def sans_initial_node(relation_hash, initial_node, direction = :out)
        return if relation_hash.nil? or relation_hash.empty?
        last_relationship = nil
        relation_hash.each do |name, relationship|
          rel_type = name.underscore
          relationship_array = relationship.map do |rel|
            if initial_node.class.relationship_names.include?(rel_type.to_sym)
              node_class     = rel[:node][:type].constantize
              related_node   = node_class.new(rel[:node].except(:id))
              related_node.instance_variable_set('@id', rel[:node][:id])
              rel_class      = rel[:rel][:type].camelize.constantize
              rel_attributes = rel_class.attributes.inject({}) do |memo, (k, v)|
                memo[k]   = rel[:rel][k]
                memo
              end
              if direction == :in
                relationship   = rel_class.new(related_node, initial_node, rel_attributes)
              else
                relationship   = rel_class.new(initial_node, related_node, rel_attributes)
              end
              last_relationship = relationship
              relationship.instance_variable_set('@id', rel[:rel][:id])
              relationship
            end
          end
          if direction
            initial_node.send("#{rel_type}_#{direction}=", relationship_array.compact) if initial_node.class.relationship_names.include?(rel_type.to_sym)
          else
            initial_node.send("#{rel_type}=", relationship_array.compact) if initial_node.class.relationship_names.include?(rel_type.to_sym)
          end
        end
        last_relationship
      end

    end
  end
end