module Deja
  module Cast

    extend ActiveSupport::Concern

    # creating relationships to be attached to already exisitng objects
    def erectify(hash)
      self.class.sans_initial_node(hash, self)
    end

    module ClassMethods
      # creating objects and their relationships (if any)
      def objectify(array)
        return nil if array.empty?
        with_initial_node(array)
      end

      def relationize(array)
        return nil if array.empty?
        with_initial_node(array, false)
      end

      def with_initial_node(entity_array, return_node = true)
        node_class = entity_array.first[:type].constantize
        initial_node = node_class.new(entity_array.first.except(:id).except(:relationships))
        initial_node.instance_variable_set('@id', entity_array.first[:id])
        relationship = sans_initial_node(entity_array.first[:relationships], initial_node)
        return_node ? initial_node : relationship
      end

      def sans_initial_node(relation_hash, initial_node)
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
              relationship   = rel_class.new(initial_node, related_node, rel_attributes)
              last_relationship = relationship
              relationship.instance_variable_set('@id', rel[:rel][:id])
              [related_node, relationship]
            end
          end
          initial_node.send("#{rel_type}=", relationship_array.compact) if initial_node.class.relationship_names.include?(rel_type.to_sym)
        end
        last_relationship
      end

    end
  end
end
