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

      def with_initial_node(entity_array)
        initial_node = self.new(entity_array.first.except(:id).except(:relationships))
        initial_node.instance_variable_set('@id', entity_array.first[:id])
        sans_initial_node(entity_array.first[:relationships], initial_node)
        initial_node
      end

      def sans_initial_node(relation_hash, initial_node)
        return if relation_hash.nil? or relation_hash.empty?
        relation_hash.each do |name, relationship|
          relationship_array = relationship.map do |rel|
            if self.relationship_names.include?(rel[:rel][:type].to_sym)
              node_class     = rel[:node][:type].constantize
              related_node   = node_class.new(rel[:node].except(:id))
              related_node.instance_variable_set('@id', rel[:node][:id])
              rel_class      = rel[:rel][:type].camelize.constantize
              rel_attributes = rel_class.attributes.inject({}) do |memo, (k, v)|
                memo[k]   = rel[:rel][k]
                memo
              end
              relationship   = rel_class.new(rel[:rel][:type], initial_node, related_node, 'both', rel_attributes)
              relationship.instance_variable_set('@id', rel[:rel][:id])
              [related_node, relationship]
            end
          end
          initial_node.send("#{name}=", relationship_array.compact) if self.relationship_names.include?(name.to_sym)
        end
      end

    end
  end
end
